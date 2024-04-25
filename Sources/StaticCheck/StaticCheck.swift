//
//  StaticCheck.swift
//
//
//  Created by Mikhail Apurin on 2024-04-10.
//

import Foundation
import ArgumentParser

import UniformTypeIdentifiers

@main
struct StaticCheck: AsyncParsableCommand {
    enum Format: String, Decodable, ExpressibleByArgument {
        case string
        case markdown

        init?(argument: String) {
            self.init(rawValue: argument)
        }

    }

    @Option var format: Format = .string

    @Argument(completion: .file(), transform: { URL.init(filePath: $0) }) var binaryPath: URL

    func run() async throws {
        let main = Binary(
            id: .main,
            url: binaryPath
        )
        let extractor = BinarySymbolExtractor()
        do {
            let data = try await extractor.extract(from: main)
            let report = StaticCheckReport.generate(from: .init(extractedData: data))
            switch format {
            case .string:
                print(report.formatted(.string))

            case .markdown:
                print(report.formatted(.markdown))
            }
        } catch {
            throw error
        }
    }
}
