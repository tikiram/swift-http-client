// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "http_client",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "http_client",
            targets: ["http_client"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "http_client"),
        .testTarget(
            name: "http_clientTests",
            dependencies: ["http_client"]),
    ]
)
