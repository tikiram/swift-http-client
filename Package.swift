// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-http-client",
    platforms: [
      .iOS(.v17),
      .macCatalyst(.v17),
      .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HTTPClient",
            targets: ["HTTPClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HTTPClient",
            dependencies: [
              .product(name: "HTTPTypes", package: "swift-http-types"),
              .product(name: "HTTPTypesFoundation", package: "swift-http-types")
            ]
        ),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: ["HTTPClient"]),
    ]
)
