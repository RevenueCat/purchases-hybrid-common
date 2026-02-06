// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PurchasesHybridCommon",
    platforms: [
        .macOS(.v10_15),
        .watchOS("6.2"),
        .tvOS(.v13),
        .iOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PurchasesHybridCommon",
            targets: ["PurchasesHybridCommon"]),
        .library(
            name: "PurchasesHybridCommonUI",
            targets: ["PurchasesHybridCommonUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios-spm", exact: "5.57.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PurchasesHybridCommon",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
            ],
            path: "ios/PurchasesHybridCommon/PurchasesHybridCommon"),
        .target(
            name: "PurchasesHybridCommonUI",
            dependencies: [
                .target(name: "PurchasesHybridCommon"),
                .product(name: "RevenueCatUI", package: "purchases-ios-spm"),
            ],
            path: "ios/PurchasesHybridCommon/PurchasesHybridCommonUI"),
    ]
)