// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swift-dependencies-static-check",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "static-check",
            targets: ["StaticCheck"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.3.1"
        ),
    ],
    targets: [
        .executableTarget(
            name: "StaticCheck",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "StaticCheckTests",
            dependencies: ["StaticCheck"]
        ),
    ]
)
