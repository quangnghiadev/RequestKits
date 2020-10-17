//
//  Logger.swift
//
//
//  Created by Nghia Nguyen on 5/29/20.
//

import Foundation

// MARK: Logger

func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    print("[\(file.components(separatedBy: "/").last ?? ""):\(line)] [\(function)] \(message)")
    #endif
}
