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

extension StaticCheckReport {
    struct StringFormatStyle: FormatStyle {
        func format(_ value: StaticCheckReport) -> String {
            value.binaries.map { binary in
                (
                    [
                        "\(ResultSymbol(binary.isSuccess)) \(binary.validCount)/\(binary.conformances.count) for \(binary.binary.name) at \(binary.binary.url.filePath)"
                    ]
                    + binary.conformances.map { report in
                        "\t\(ResultSymbol(report.conformance.isSuccess)) \(report.symbol)"
                    }
                ).joined(separator: "\n")
            }
            .joined(separator: "\n")
        }
    }

    struct MarkdownFormatStyle: FormatStyle {
        func format(_ value: StaticCheckReport) -> String {
            value.binaries.map { binary in
                (
                    [
                        "### \(ResultSymbol(binary.isSuccess)) \(binary.binary.name) (\(binary.validCount)/\(binary.conformances.count))",
                        "",
                        "| Status | Dependency |",
                        "|---|---|"
                    ]
                    + binary.conformances.map { report in
                        "| \(ResultSymbol(report.conformance.isSuccess)) | \(report.symbol) |"
                    }
                ).joined(separator: "\n")
            }
            .joined(separator: "\n")
        }
    }

    func formatted<Style: FormatStyle>(_ style: Style) -> Style.FormatOutput where Style.FormatInput == StaticCheckReport {
        style.format(self)
    }
}

extension FormatStyle where Self == StaticCheckReport.StringFormatStyle  {
    static var string: Self {
        .init()
    }
}

extension FormatStyle where Self == StaticCheckReport.MarkdownFormatStyle  {
    static var markdown: Self {
        .init()
    }
}
