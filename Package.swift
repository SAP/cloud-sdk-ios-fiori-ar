// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FioriARKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        // TODO: offer a library which requiresToEmbedXCFrameworks by app developers
        .library(
            name: "FioriARKit",
            targets: ["FioriARKit"]
        )
    ],
    dependencies: [
        .package(name: "FioriSwiftUI", url: "https://github.com/SAP/cloud-sdk-ios-fiori.git", .upToNextMinor(from: "1.0.1")),
        .package(name: "cloud-sdk-ios", url: "https://github.com/SAP/cloud-sdk-ios", .exact("6.1.2-xcfrwk"))
    ],
    targets: [
        // TODO: offer target withoutBinaryDependencies for library product which requiresToEmbedXCFrameworks by app developers
        .target(
            name: "FioriARKit",
            dependencies: [
                "FioriSwiftUI",
                .product(name: "SAPFoundation", package: "cloud-sdk-ios"),
                .product(name: "SAPCommon", package: "cloud-sdk-ios")
            ],
            exclude: [
                "Networking/README.md",
                "Networking/internal/README.md"
            ],
            resources: [.process("ARCards/Resources")]
        ),
        .testTarget(
            name: "FioriARKitTests",
            dependencies: ["FioriARKit"],
            resources: [.process("TestResources")]
        )
    ]
)
