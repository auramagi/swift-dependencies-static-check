//
//  ErrorMessage.swift
//  
//
//  Created by Mikhail Apurin on 2024-04-10.
//

import Foundation

struct ErrorMessage: LocalizedError {
    let message: String

    let underlying: Error?

    var errorDescription: String? {
        message
    }
}

extension Error where Self == ErrorMessage {
    static func message(_ message: String, underlying: Error? = nil) -> Self {
        .init(message: message, underlying: underlying)
    }
}
