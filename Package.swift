// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GRDBKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(name: "GRDBKit", targets: ["GRDBKit"])
    ],
    dependencies: [
        .package(name: "GRDB", url: "https://github.com/groue/GRDB.swift.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "GRDBKit", dependencies: [
            .product(name: "GRDB", package: "GRDB")
        ]),
        .testTarget(name: "GRDBKitTests", dependencies: [
            .target(name: "GRDBKit")
        ]),
    ]
)
