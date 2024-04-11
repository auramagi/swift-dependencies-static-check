//
//  ProtocolConformance.swift
//
//
//  Created by Mikhail Apurin on 2024-04-11.
//

import Foundation

struct ProtocolConformance: Hashable, CustomStringConvertible {
    let symbol: QualifiedSymbol
    
    let `protocol`: QualifiedSymbol
    
    let module: String
    
    var description: String {
        "\(symbol) : \(`protocol`) in \(module)"
    }
}

extension ProtocolConformance {
    //  protocol conformance descriptor for SymbolModule.SymbolName : ProtocolModule.ProtocolName in ConformanceModule
    private static let regex = #/protocol conformance descriptor for (?P<symbol>.+?) : (?P<protocol>.+?) in (?P<module>.+?)/#
    
    init?(parsing string: String) {
        guard let match = string.wholeMatch(of: Self.regex),
              let symbol = QualifiedSymbol(parsing: match.symbol),
              let `protocol` = QualifiedSymbol(parsing: match.protocol),
              case let module = String(match.module)
        else { return nil }
        self.init(
            symbol: symbol,
            protocol: `protocol`,
            module: module
        )
    }
}

