//
//  StaticCheckReport.swift
//
//
//  Created by Mikhail Apurin on 2024/04/25.
//

import Foundation

struct StaticCheckReport {
    struct BinaryReport {
        let isSuccess: Bool

        let validCount: Int

        let binary: Binary

        let conformances: [ConformanceReport]
    }

    struct ConformanceReport {
        let symbol: QualifiedSymbol

        let conformance: DependencyKeyConformance
    }

    struct DependencyKeyConformance {
        var isSuccess: Bool

        var dependencyKey: [(Binary.ID, ProtocolConformance)]

        var testDependencyKey: [(Binary.ID, ProtocolConformance)]
    }

    struct Input {
        let extractedData: BinarySymbolExtractor.ExtractionResult
    }

    let binaries: [BinaryReport]
}

extension StaticCheckReport {
    static func generate(from input: Input) -> Self {
        let binary = input.extractedData.binary
        var conformanceReports: [ConformanceReport] = []
        for (symbol, conformances) in input.extractedData.conformances {
            let dependencyKey = conformances.filter { $0.protocol == .dependencyKey }.map { (binary.id, $0) }
            let testDependencyKey = conformances.filter { $0.protocol == .testDependencyKey }.map { (binary.id, $0) }
            conformanceReports.append(
                ConformanceReport(
                    symbol: symbol,
                    conformance: .init(
                        isSuccess: dependencyKey.count == 1 && testDependencyKey.count == 1,
                        dependencyKey: dependencyKey,
                        testDependencyKey: testDependencyKey
                    )
                )
            )
        }
        let validCount = conformanceReports.filter(\.conformance.isSuccess).count

        return .init(
            binaries: [
                .init(
                    isSuccess: validCount == conformanceReports.count,
                    validCount: validCount,
                    binary: binary,
                    conformances: conformanceReports
                        .sorted(by: { $0.symbol.description < $1.symbol.description })
                )
            ].sorted { $0.binary.sort < $1.binary.sort }
        )
    }

    func printReport() {
        for binary in binaries {
            print("\(ResultSymbol(binary.isSuccess)) \(binary.validCount)/\(binary.conformances.count) for \(binary.binary.name) at \(binary.binary.url.filePath)")
            for report in binary.conformances {
                print("\t\(ResultSymbol(report.conformance.isSuccess)) \(report.symbol)")
            }
        }
    }
}

enum ResultSymbol: String, CustomStringConvertible {
    case success = "✅"

    case failure = "❌"

    var description: String {
        rawValue
    }

    init(_ value: Bool) {
        if value {
            self = .success
        } else {
            self = .failure
        }
    }
}
