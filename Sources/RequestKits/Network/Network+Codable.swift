//
//  File.swift
//
//
//  Created by Nghia Nguyen on 31/03/2021.
//

// MARK: Support Decodable Response

import Alamofire
import Foundation

public extension Network {
    @discardableResult
    func request<T>(requestable: T, completion: @escaping (Result<T.Response, Error>) -> Void) -> Request where T: Requestable, T.Response: Decodable {
        return request(requestable: requestable) { data, error in
            if let err = error {
                completion(.failure(err))
            } else {
                completion(self.decodeResponse(data: data, atKeyPath: requestable.keyPath))
            }
        }
    }

    @discardableResult
    func upload<T>(requestable: T, progress: Request.ProgressHandler? = nil, completion: @escaping (Result<T.Response, Error>) -> Void) -> Request where T: Requestable, T.Response: Decodable {
        return upload(requestable: requestable, progress: progress) { data, error in
            if let err = error {
                completion(.failure(err))
            } else {
                completion(self.decodeResponse(data: data, atKeyPath: requestable.keyPath))
            }
        }
    }
}

// MARK: Helper

private extension Network {
    private func decodeResponse<T: Decodable>(data: Data?, atKeyPath keyPath: String? = nil) -> Result<T, Error> {
        do {
            let resultObject: T
            if let keyPath = keyPath {
                resultObject = try decoder.decode(T.self, from: data ?? Data(), keyPath: keyPath)
            } else {
                resultObject = try decoder.decode(T.self, from: data ?? Data())
            }
            return .success(resultObject)
        } catch {
            errorReporter?.report(error: error)
            log("Decoding with error: \((error as NSError).userInfo)")
            return .failure(NetworkError.objectMapping(error, nil))
        }
    }
}
