//
//  PostAnything.swift
//  RequestKitsDemo
//
//  Created by Nghia Nguyen on 31/03/2021.
//

import Foundation
import RequestKits
import Alamofire

struct PostAnything: Requestable {
    typealias Response = AnyThingResponse

    var baseURL: URL {
        return URL(string: "http://httpbin.org")!
    }

    var path: String {
        return "/anything"
    }

    var method: HTTPMethod {
        return .post
    }

    var task: Task {
        return .requestParameters(parameters: ["id": UUID().uuidString, "name": "Stuart"], encoding: JSONEncoding.default)
    }

    var keyPath: String? {
        return "json"
    }
}
