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
        let file = URL(filePath: "/Users/Apurin/Library/Developer/Xcode/DerivedData/TestApp-fndppwapcovmqoczofsmeoiggobx/Build/Products/Release-iphonesimulator/TestApp.app/TestApp")
        // nm: output symbols in a binary
        // - g: only external symbols
        // - U: hide undefined
        // - j: output only symbol names
        // - s: specify segname + sectname
        // swift demangle: demangle mangled swift symbols
        let symbols = try await shell("nm -gUj -s __TEXT __const \(file) | swift demangle")
        let conformances = Dictionary(
            grouping: symbols
                .components(separatedBy: "\n")
                .compactMap { ProtocolConformance(parsing: $0) },
            by: \.symbol
        )
            .mapValues { $0.filter { [.dependencyKey, .testDependencyKey].contains($0.protocol) } }
            .filter { !$1.isEmpty }
        for (key, value) in conformances {
            print(key, value)
        }
    }
}
