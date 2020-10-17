//
//  NetworkConfig.swift
//  RequestKits
//
//  Created by Nghia Nguyen on 4/14/20.
//  Copyright © 2020 Nghia Nguyen. All rights reserved.
//

import Alamofire
import Foundation

public struct NetworkConfig {
    public let decoder: JSONDecoder
    public let errorReporter: ErrorReportable?
    public let requestAdapters: [RequestAdapter]
    public let requestRetrier: [RequestRetrier]
    public let eventMonitors: [EventMonitor]

    public init(decoder: JSONDecoder = JSONDecoder(),
                errorReporter: ErrorReportable? = nil,
                requestAdapters: [RequestAdapter] = [],
                requestRetrier: [RequestRetrier] = [],
                eventMonitors: [EventMonitor] = [NetworkLogger(level: .lite)])
    {
        self.decoder = decoder
        self.errorReporter = errorReporter
        self.requestAdapters = requestAdapters
        self.requestRetrier = requestRetrier
        self.eventMonitors = eventMonitors
    }

    var interceptor: Interceptor? {
        return Interceptor(adapters: requestAdapters, retriers: requestRetrier + [ConnectionLostRetryPolicy()])
    }
}
