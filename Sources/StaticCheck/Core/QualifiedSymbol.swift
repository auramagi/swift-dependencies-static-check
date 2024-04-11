//
//  QualifiedSymbol.swift
//
//
//  Created by Mikhail Apurin on 2024-04-11.
//

import Foundation

struct QualifiedSymbol: Hashable, CustomStringConvertible {
    let module: String
    
    let name: String
    
    var description: String {
        "\(module).\(name)"
    }
}

extension QualifiedSymbol {
    init?(parsing string: some StringProtocol) {
        guard case let components = string.split(separator: ".", maxSplits: 1),
              components.count == 2,
              case let module = String(components[0]),
              !module.isEmpty,
              case let name = String(components[1]),
              !name.isEmpty
        else { return nil }
        self.init(module: module, name: name)
    }
}

extension QualifiedSymbol {
    static let dependencyKey = Self(module: "Dependencies", name: "DependencyKey")
    
    static let testDependencyKey = Self(module: "Dependencies", name: "TestDependencyKey")
}
