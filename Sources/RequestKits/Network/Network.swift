//
//  Networking.swift
//  RequestKits
//
//  Created by Nghia Nguyen on 4/7/20.
//  Copyright © 2020 Nghia Nguyen. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

public struct Network {
    private let errorReporter: ErrorReportable?
    private let session: Session
    private let decoder: JSONDecoder

    public init(config: NetworkConfig = NetworkConfig()) {
        self.decoder = config.decoder
        self.errorReporter = config.errorReporter
        self.session = Session(interceptor: config.interceptor, eventMonitors: config.eventMonitors)
    }

    // Data Request
    @discardableResult
    public func request(_ convertible: URLRequestConvertible, validationType: ValidationType, completion: @escaping (Data?, Error?) -> Void) -> Cancellable {
        var request: DataRequest = session.request(convertible)
        if validationType != .none {
            request = request.validate(statusCode: validationType.statusCodes)
        }

        return RequestManager.instance.addOperation(request: request) { response in
            switch response.result {
            case let .success(data):
                completion(data, nil)
            case let .failure(error):
                self.errorReporter?.report(error: error)
                completion(nil, NetworkError.underlying(error, Response(response)))
            }
        }
    }

    // Data Download
    @discardableResult
    public func download(_ convertible: URLRequestConvertible, validationType: ValidationType, progress: Request.ProgressHandler? = nil,
                         destination: DownloadRequest.Destination = DownloadRequest.suggestedDownloadDestination(), completion: @escaping (URL?, Error?) -> Void) -> Cancellable
    {
        var request: DownloadRequest = session.download(convertible)
        if validationType != .none {
            request = request.validate(statusCode: validationType.statusCodes)
        }

        if let progress = progress {
            request = request.downloadProgress(closure: progress)
        }

        return DownloadManager.instance.addOperation(request: request) { response in
            switch response.result {
            case let .success(fileURL):
                completion(fileURL, nil)
            case let .failure(error):
                self.errorReporter?.report(error: error)
                completion(nil, NetworkError.underlying(error, Response(response)))
            }
        }
    }

    // Data Upload
    @discardableResult
    public func upload(_ convertible: URLRequestConvertible, validationType: ValidationType, multipartFormData: MultipartFormData, progress: Request.ProgressHandler? = nil, completion: @escaping (Data?, Error?) -> Void) -> Cancellable {
        var request = session.upload(multipartFormData: multipartFormData, with: convertible)
        if validationType != .none {
            request = request.validate(statusCode: validationType.statusCodes)
        }

        if let progress = progress {
            request = request.uploadProgress(closure: progress)
        }

        return UploadManager.instance.addOperation(request: request) { response in
            switch response.result {
            case let .success(data):
                completion(data, nil)
            case let .failure(error):
                self.errorReporter?.report(error: error)
                completion(nil, NetworkError.underlying(error, Response(response)))
            }
        }
    }
}

// MARK: Request with requestable

public extension Network {
    @discardableResult
    func request<T: Requestable>(requestable: T, completion: @escaping (Data?, Error?) -> Void) -> Cancellable {
        return sendRequest(requestable: requestable) { data, _, error in
            completion(data, error)
        }
    }

    @discardableResult
    func download<T: Requestable>(requestable: T, progress: Request.ProgressHandler? = nil, completion: @escaping (URL?, Error?) -> Void) -> Cancellable {
        return sendRequest(requestable: requestable, progress: progress) { _, url, error in
            completion(url, error)
        }
    }

    @discardableResult
    func upload<T: Requestable>(requestable: T, progress: Request.ProgressHandler? = nil, completion: @escaping (Data?, Error?) -> Void) -> Cancellable {
        return sendRequest(requestable: requestable, progress: progress) { data, _, error in
            completion(data, error)
        }
    }

    @discardableResult
    private func sendRequest<T: Requestable>(requestable: T, progress: Request.ProgressHandler? = nil, completion: @escaping (Data?, URL?, Error?) -> Void) -> Cancellable {
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

// MARK: Support Codable Response

public extension Network {
    @discardableResult
    func request<T, H>(requestable: T, completion: @escaping (Result<H, Error>) -> Void) -> Cancellable where T: Requestable, H: Decodable {
        return request(requestable: requestable) { data, error in
            if let err = error {
                completion(.failure(err))
            } else {
                completion(self.decodeResponse(data: data, atKeyPath: requestable.keyPath))
            }
        }
    }

    @discardableResult
    func upload<T, H>(requestable: T, progress: Request.ProgressHandler? = nil, completion: @escaping (Result<H, Error>) -> Void) -> Cancellable where T: Requestable, H: Decodable {
        return upload(requestable: requestable, progress: progress) { data, error in
            if let err = error {
                completion(.failure(err))
            } else {
                completion(self.decodeResponse(data: data, atKeyPath: requestable.keyPath))
            }
        }
    }
}

// MARK: Support Reactive Programming

public extension Network {
    func rxRequest<T, H>(requestable: T, atKeyPath keyPath: String? = nil) -> Observable<H> where T: Requestable, H: Decodable {
        return Observable<H>.create { (observer) -> Disposable in
            let cancelable = self.request(requestable: requestable) { (result: Result<H, Error>) in
                switch result {
                case let .success(object):
                    observer.onNext(object)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                cancelable.cancel()
            }
        }
    }

    func rxDownload<T>(requestable: T, progress: Request.ProgressHandler? = nil) -> Observable<URL> where T: Requestable {
        return Observable<URL>.create { (observer) -> Disposable in
            let cancelable = self.download(requestable: requestable, progress: progress) { url, error in
                if let err = error {
                    observer.onError(err)
                } else {
                    observer.onNext(url!)
                    observer.onCompleted()
                }
            }
            return Disposables.create {
                cancelable.cancel()
            }
        }
    }

    func rxUpload<T, H>(requestable: T, atKeyPath keyPath: String? = nil, progress: Request.ProgressHandler? = nil) -> Observable<H> where T: Requestable, H: Decodable {
        return Observable<H>.create { (observer) -> Disposable in
            let cancelable = self.upload(requestable: requestable, progress: progress) { (result: Result<H, Error>) in
                switch result {
                case let .success(object):
                    observer.onNext(object)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                cancelable.cancel()
            }
        }
    }
}

// MARK: Helper

private extension Network {
    private func decodeResponse<H: Decodable>(data: Data?, atKeyPath keyPath: String? = nil) -> Result<H, Error> {
        do {
            let resultObject: H
            if let keyPath = keyPath {
                resultObject = try decoder.decode(H.self, from: data ?? Data(), keyPath: keyPath)
            } else {
                resultObject = try decoder.decode(H.self, from: data ?? Data())
            }
            return .success(resultObject)
        } catch {
            errorReporter?.report(error: error)
            return .failure(NetworkError.objectMapping(error, nil))
        }
    }
}
