//
//  HeaderRequest.swift
//  RequestKitsDemo
//
//  Created by Nghia Nguyen on 31/03/2021.
//

import Alamofire
import Foundation
import RequestKits

struct HeaderRequest: Requestable {
    typealias Response = HeaderResponse

    var baseURL: URL {
        return URL(string: "http://httpbin.org/")!
    }

    var path: String {
        return "headers"
    }

    var method: HTTPMethod {
        return .get
    }

    var task: Task {
        .requestPlain
    }

    var keyPath: String? {
        return "headers"
    }
}
