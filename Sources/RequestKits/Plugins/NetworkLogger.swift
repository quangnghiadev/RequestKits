//
//  NetworkLogger.swift
//  RequestKits
//
//  Created by Nghia Nguyen on 4/14/20.
//  Copyright © 2020 Nghia Nguyen. All rights reserved.
//

import Alamofire
import Foundation

public struct NetworkLogger: EventMonitor {
    public enum Level: String {
        case full
        case lite
    }

    private let level: Level
    public let queue = DispatchQueue(label: "com.requestkits.logger", qos: .utility, attributes: .concurrent)

    public init(level: Level = .lite) {
        self.level = level
    }

    public func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        let requestBasicInfo = """
        ______________[Request]______________
        [URL]: \(response.request?.url?.absoluteString ?? "")
        [Method]: \(response.request?.httpMethod ?? "")
        """
        let requestHeader = "[Headers]: \n\(response.response?.headers.sorted() ?? [:])"
        let requestBody = "[Body]: \n\(response.request?.httpBody.map { getPrettyPrintedJSON(data: $0) } ?? "None")"

        let responseBasicInfo = """
        ______________[Response]______________
        [Status Code]: \(response.response?.statusCode ?? 0)
        """
        let responseHeader = "[Headers]: \n\(response.response?.headers.sorted() ?? [:])"
        let responseBody = "[Body]: \n\(response.data.map { getPrettyPrintedJSON(data: $0) } ?? "None")"
        let responseTime = "[Duration]: \(response.metrics.map { "\($0.taskInterval.duration)s" } ?? "None")"

        var message = ""

        switch level {
        case .lite:
            message = [requestBasicInfo, responseBasicInfo, responseTime].joined(separator: "\n")
        case .full:
            message = [requestBasicInfo, requestHeader, requestBody, responseBasicInfo, responseTime, responseHeader, responseBody].joined(separator: "\n")
        }

        queue.async {
            print(
                """
                ________________________________________________________________
                \(message)
                ________________________________________________________________
                """
            )
        }
    }

    private func getPrettyPrintedJSON(data: Data) -> String {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = String(data: data, encoding: .utf8) else { return "None" }
        return prettyPrintedString
    }
}
