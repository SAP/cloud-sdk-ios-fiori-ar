// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FioriAR",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FioriAR",
            targets: ["FioriAR-withBinaryDependencies"]
        ),
        .library(
            name: "FioriAR-requiresToEmbedXCFrameworks",
            targets: ["FioriAR-withoutBinaryDependencies"]
        )
    ],
    dependencies: [
        .package(name: "FioriSwiftUI", url: "https://github.com/SAP/cloud-sdk-ios-fiori.git", .upToNextMajor(from: "2.0.0")),
        .package(name: "cloud-sdk-ios", url: "https://github.com/SAP/cloud-sdk-ios", .exact("6.1.2-xcfrwk"))
    ],
    targets: [
        .target(
            name: "FioriAR-withBinaryDependencies",
            dependencies: [
                "FioriAR",
                .product(name: "SAPFoundation", package: "cloud-sdk-ios"),
                .product(name: "SAPCommon", package: "cloud-sdk-ios")
            ]
        ),
        .target(
            name: "FioriAR",
            dependencies: ["FioriSwiftUI"],
            exclude: [
                "Networking/README.md",
                "Networking/internal/README.md"
            ],
            resources: [.process("ARCards/Resources")]
        ),
        .target(
            name: "FioriAR-withoutBinaryDependencies",
            dependencies: [
                "FioriAR"
            ],
            linkerSettings: [
                .linkedFramework("SAPCommon"),
                .linkedFramework("SAPFoundation")
            ]
        ),
        .testTarget(
            name: "FioriARTests",
            dependencies: ["FioriAR"],
            resources: [.process("TestResources")]
        )
    ]
)
