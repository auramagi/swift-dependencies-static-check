//
//  BinarySymbolExtractor.swift
//  
//
//  Created by Mikhail Apurin on 2024/04/11.
//

import Foundation

struct BinarySymbolExtractor {
    struct ExtractionResult {
        let binary: Binary

        let conformances: [QualifiedSymbol: [ProtocolConformance]]
    }

    func extract(from binary: Binary) async throws -> ExtractionResult {
        // nm: output symbols in a binary
        // - g: only external symbols
        // - U: hide undefined
        // - j: output only symbol names
        // - s: specify segname + sectname
        // swift demangle: demangle mangled swift symbols
        let symbols = try await shell("nm -gUj -s __TEXT __const \(binary.url) | swift demangle")
        let allConformances = Dictionary(
            grouping: symbols
                .components(separatedBy: "\n")
                .compactMap { ProtocolConformance(parsing: $0) },
            by: \.symbol
        )
        return .init(
            binary: binary,
            conformances: allConformances
                .mapValues { $0.filter { [.dependencyKey, .testDependencyKey].contains($0.protocol) } }
                .filter { !$0.value.isEmpty }
        )
    }
}
