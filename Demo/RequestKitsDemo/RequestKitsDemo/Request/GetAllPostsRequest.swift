//
//  GetAllPostsRequest.swift
//  RequestKitsDemo
//
//  Created by Nghia Nguyen on 31/03/2021.
//

import Foundation
import RequestKits
import Alamofire

struct GetAllPostsRequest: Requestable {
    typealias Response = Data

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
}
