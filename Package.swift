// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GRDBKit",
    products: [
        .library(name: "GRDBKit", targets: ["GRDBKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "4.5.0")
    ],
    targets: [
        .target(name: "GRDBKit", dependencies: ["GRDB"], path: "GRDBKit", exclude: ["GRDBKit.h","Info.plist"]),
        .testTarget(name: "GRDBKitTests", dependencies: ["GRDB", "GRDBKit"], path: "GRDBKitTests"),
    ]
)
