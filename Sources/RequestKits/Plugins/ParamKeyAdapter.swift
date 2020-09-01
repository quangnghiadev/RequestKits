//
//  ParamKeyAdapter.swift
//
//
//  Created by Nguyen Nghia on 9/1/20.
//

import Alamofire
import Foundation

public class ParamKeyAdapter: RequestAdapter {
    private let keyName: String
    private let keyValue: String

    public init(keyName: String, keyValue: String) {
        self.keyName = keyName
        self.keyValue = keyValue
    }

    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        do {
            urlRequest = try URLEncoding.default.encode(urlRequest, with: [keyName: keyValue])
            completion(.success(urlRequest))
        } catch {
            completion(.failure(error))
        }
    }
}
