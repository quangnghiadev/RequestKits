//
//  File.swift
//  
//
//  Created by Nghia Nguyen on 5/29/20.
//

import Foundation

// MARK: Logger

func log(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}