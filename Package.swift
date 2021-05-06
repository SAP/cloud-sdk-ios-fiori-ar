// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

import PackageDescription

let package = Package(
    name: "FioriARKit",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FioriARKit",
            targets: ["FioriARKit"]),
    ],
    dependencies: [

        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
//        .package(name: "FioriSwiftUI",
//                 url: "https://github.com/SAP/cloud-sdk-ios-fiori.git",
//                 .branch("migration")
//        )
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FioriARKit",
            dependencies: []),
        .testTarget(
            name: "FioriARKitTests",
            dependencies: ["FioriARKit"]),
    ]
)
