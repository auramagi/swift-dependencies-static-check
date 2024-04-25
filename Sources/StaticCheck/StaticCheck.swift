//
//  StaticCheck.swift
//
//
//  Created by Mikhail Apurin on 2024-04-10.
//

import Foundation
import ArgumentParser

@main
struct StaticCheck: AsyncParsableCommand {
    func run() async throws {
        let main = Binary(
            id: .main,
            url: URL(filePath: "")
        )
        let extractor = BinarySymbolExtractor()
        do {
            let data = try await extractor.extract(from: main)
            let report = StaticCheckReport.generate(from: .init(extractedData: data))
            report.printReport()
        } catch {
            throw error
        }
    }
}
