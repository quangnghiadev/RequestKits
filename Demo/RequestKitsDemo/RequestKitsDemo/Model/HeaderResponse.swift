//
//  HeaderResponse.swift
//  RequestKitsDemo
//
//  Created by Nghia Nguyen on 31/03/2021.
//

import Foundation

struct HeaderResponse: Decodable {
    let acceptType: AcceptType

    enum CodingKeys: String, CodingKey {
        case acceptType = "Accept"
    }
}

enum AcceptType: String, Decodable {
    case json = "application/json"
    case unknown
}
