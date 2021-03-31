//
//  Networking.swift
//  RequestKits
//
//  Created by Nghia Nguyen on 4/7/20.
//  Copyright © 2020 Nghia Nguyen. All rights reserved.
//

import Alamofire
import Foundation

public struct Network {
    let errorReporter: ErrorReportable?
    let session: Session
    let decoder: JSONDecoder

    public init(config: NetworkConfig = NetworkConfig()) {
        self.decoder = config.decoder
        self.errorReporter = config.errorReporter
        self.session = Session(interceptor: config.interceptor, eventMonitors: config.eventMonitors)
    }

    // Data Request
    @discardableResult
    public func request(_ convertible: URLRequestConvertible,
                        validationType: ValidationType,
                        completion: @escaping (Data?, Error?) -> Void) -> Request
    {
        var request: DataRequest = session.request(convertible)
        if validationType != .none, !validationType.statusCodes.isEmpty {
            request = request.validate(statusCode: validationType.statusCodes)
        }
        return request.response { dataResponse in
            switch dataResponse.result {
            case let .success(data):
                completion(data, nil)
            case let .failure(error):
                self.errorReporter?.report(error: error)
                completion(nil, NetworkError.underlying(error, Response(dataResponse)))
            }
        }
    }

    // Data Download
    @discardableResult
    public func download(_ convertible: URLRequestConvertible,
                         validationType: ValidationType,
                         progress: Request.ProgressHandler? = nil,
                         destination: DownloadRequest.Destination = DownloadRequest.suggestedDownloadDestination(),
                         completion: @escaping (URL?, Error?) -> Void) -> Request
    {
        var request: DownloadRequest = session.download(convertible)
        if validationType != .none, !validationType.statusCodes.isEmpty {
            request = request.validate(statusCode: validationType.statusCodes)
        }
        if let progress = progress {
            request = request.downloadProgress(closure: progress)
        }
        return request.response { downloadResponse in
            switch downloadResponse.result {
            case let .success(fileURL):
                completion(fileURL, nil)
            case let .failure(error):
                self.errorReporter?.report(error: error)
                completion(nil, NetworkError.underlying(error, Response(downloadResponse)))
            }
        }
    }

    // Data Upload
    @discardableResult
    public func upload(_ convertible: URLRequestConvertible,
                       validationType: ValidationType,
                       multipartFormData: MultipartFormData,
                       progress: Request.ProgressHandler? = nil,
                       completion: @escaping (Data?, Error?) -> Void) -> Request
    {
        var request = session.upload(multipartFormData: multipartFormData, with: convertible)
        if validationType != .none, !validationType.statusCodes.isEmpty {
            request = request.validate(statusCode: validationType.statusCodes)
        }
        if let progress = progress {
            request = request.uploadProgress(closure: progress)
        }
        return request.response { dataResponse in
            switch dataResponse.result {
            case let .success(data):
                completion(data, nil)
            case let .failure(error):
                self.errorReporter?.report(error: error)
                completion(nil, NetworkError.underlying(error, Response(dataResponse)))
            }
        }
    }
}

// MARK: Request with Requestable

public extension Network {
    @discardableResult
    func request<T: Requestable>(requestable: T, completion: @escaping (Data?, Error?) -> Void) -> Request {
        return sendRequest(requestable: requestable) { data, _, error in
            completion(data, error)
        }
    }

    @discardableResult
    func download<T: Requestable>(requestable: T, progress: Request.ProgressHandler? = nil, completion: @escaping (URL?, Error?) -> Void) -> Request {
        return sendRequest(requestable: requestable, progress: progress) { _, url, error in
            completion(url, error)
        }
    }

    @discardableResult
    func upload<T: Requestable>(requestable: T, progress: Request.ProgressHandler? = nil, completion: @escaping (Data?, Error?) -> Void) -> Request {
        return sendRequest(requestable: requestable, progress: progress) { data, _, error in
            completion(data, error)
        }
    }

    @discardableResult
    private func sendRequest<T: Requestable>(requestable: T, progress: Request.ProgressHandler? = nil, completion: @escaping (Data?, URL?, Error?) -> Void) -> Request {
        switch requestable.task {
        case let .downloadDestination(destination), let .downloadParameters(_, _, destination):
            return download(requestable, validationType: requestable.validationType, progress: progress, destination: destination) { url, error in
                completion(nil, url, error)
            }
        case let .uploadMultipart(multipartBody), let .uploadCompositeMultipart(multipartBody, _):
            return upload(requestable, validationType: requestable.validationType, multipartFormData: multipartBody, progress: progress) { data, error in
                completion(data, nil, error)
            }
        case .requestPlain, .requestJSONEncodable, .requestCustomJSONEncodable, .requestParameters, .requestCompositeParameters:
            return request(requestable, validationType: requestable.validationType) { data, error in
                completion(data, nil, error)
            }
        }
    }
}
