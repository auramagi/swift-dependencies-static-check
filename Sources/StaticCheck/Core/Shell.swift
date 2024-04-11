//
//  Shell.swift
//
//
//  Created by Mikhail Apurin on 2024-04-11.
//

import Foundation

struct Shell: ~Copyable {
    let command: ShellCommand
    
    let environment: [String: String]
    
    private let outputPipe = Pipe()
    
    private let errorPipe = Pipe()
    
    private let process = Process()
    
    init(_ command: ShellCommand, environment: [String : String] = [:]) {
        self.command = command
        self.environment = environment
    }
    
    consuming func run() -> AsyncThrowingStream<String, Error> {
        let (outputPipe, errorPipe, process) = (outputPipe, errorPipe, process)
        let environment = ProcessInfo()
            .environment
            .merging(environment) { $1 }
        process.qualityOfService = .userInteractive
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.environment = environment
        process.launchPath = environment["SHELL"] ?? "/bin/zsh"
        process.arguments = ["-c", "\(ShellCommand.pipefail) \(command.value)"]

        let (stream, continuation) = AsyncThrowingStream.makeStream(of: String.self)
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            continuation.yield(
                String(decoding: handle.availableData, as: UTF8.self)
            )
        }
        process.terminationHandler = { process in
            if process.terminationReason == .exit, process.terminationStatus == 0 {
                continuation.finish()
            } else {
                let error = try? errorPipe.fileHandleForReading
                    .readToEnd()
                    .map { String(decoding: $0, as: UTF8.self) }
                continuation.finish(throwing: .message(error ?? "Unknown error."))
            }
        }
        continuation.onTermination = { _ in
            if process.isRunning {
                process.interrupt()
            }
        }
        
        do {
            try process.run()
        } catch {
            continuation.finish(throwing: .message("Failed to run process.", underlying: error))
        }
        
        return stream
    }
    
    consuming func run() async throws -> String {
        try await run().reduce("", +)
    }
}

func shell(_ command: ShellCommand, environment: [String: String] = [:]) async throws -> String {
    try await Shell(command, environment: environment).run()
}

// MARK: - ShellCommand

struct ShellCommand: LosslessStringConvertible {
    var value: String
    
    init(_ value: String) {
        self.value = value
    }
    
    var description: String {
        value
    }
}

extension ShellCommand: ExpressibleByStringInterpolation {
    struct StringInterpolation: StringInterpolationProtocol {
        var value = ""
        
        init(literalCapacity: Int, interpolationCount: Int) {
            value.reserveCapacity(literalCapacity)
        }
        
        mutating func appendLiteral(_ literal: String) {
            value.append(literal)
        }
        
        mutating func appendInterpolation<T: CustomStringConvertible>(_ string: T) {
            value.append(wrapQuotes(string.description))
        }
        
        mutating func appendInterpolation(_ url: URL) {
            value.append(wrapQuotes(url.path(percentEncoded: false)))
        }
        
        mutating func appendInterpolation(_ command: ShellCommand) {
            value.append(command.value)
        }
        
        private func wrapQuotes(_ string: String) -> String {
            "\"\(string.description.replacingOccurrences(of: "\"", with: "\\\""))\""
        }
    }
    
    init(stringLiteral value: String) {
        self.init(value)
    }
    
    init(stringInterpolation: StringInterpolation) {
        self.init(stringInterpolation.value)
    }
}

extension ShellCommand {
    static var pipefail: Self {
        "set -e; set -o pipefail;"
    }
}
