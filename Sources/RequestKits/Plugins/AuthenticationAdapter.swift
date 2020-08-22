//
//  Authentication.swift
//  RequestKits
//
//  Created by Nghia Nguyen on 4/13/20.
//  Copyright © 2020 Nghia Nguyen. All rights reserved.
//

import Alamofire
import Foundation

public struct AuthenticationAdapter: RequestAdapter {
    public enum Authentication {
        case bearer(token: String)
        case basic(token: String)
        case credential(username: String, password: String)
        case custom(name: String, token: String)
    }

    let authentication: Authentication

    public init(authentication: Authentication) {
        self.authentication = authentication
    }

    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        switch authentication {
        case .basic(let token):
            urlRequest.headers.add(.authorization(token))
        case .bearer(let token):
            urlRequest.headers.add(.authorization(bearerToken: token))
        case .credential(let username, let password):
            urlRequest.headers.add(.authorization(username: username, password: password))
        case .custom(let name, let token):
            urlRequest.headers.add(name: name, value: token)
        }
        completion(.success(urlRequest))
    }
}
