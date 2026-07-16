// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    /// https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md
    /// Require `any` for existential types.
    .enableUpcomingFeature("ExistentialAny"),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0409-access-level-on-imports.md
    .enableUpcomingFeature("InternalImportsByDefault"),
]

let package = Package(
    name: "GRDBKit",
    platforms: [.macOS(.v26), .iOS(.v18), .watchOS(.v26)],
    products: [
        .library(name: "GRDBKit", targets: ["GRDBKit"]),
        .executable(name: "GRDBKitClient", targets: ["GRDBKitClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "603.0.2"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.11.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "GRDBKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: swiftSettings
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "GRDBKit",
            dependencies: [
                .target(name: "GRDBKitMacros"),
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            swiftSettings: swiftSettings
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "GRDBKitClient",
            dependencies: ["GRDBKit"]
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "GRDBKitMacroTests",
            dependencies: [
                .target(name: "GRDBKitMacros"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
