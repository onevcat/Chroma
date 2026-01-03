// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chroma",
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Chroma",
            targets: ["Chroma"]
        ),
        .library(
            name: "ChromaBase46Themes",
            targets: ["ChromaBase46Themes"]
        ),
        .executable(
            name: "ChromaDemo",
            targets: ["ChromaDemo"]
        ),
        .executable(
            name: "ca",
            targets: ["Ca"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "4.2.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.20.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Chroma",
            dependencies: [
                .product(name: "Rainbow", package: "Rainbow"),
            ]
        ),
        .target(
            name: "ChromaBase46Themes",
            dependencies: [
                "Chroma",
                .product(name: "Rainbow", package: "Rainbow"),
            ]
        ),
        .testTarget(
            name: "ChromaTests",
            dependencies: ["Chroma"]
        ),
        .executableTarget(
            name: "ChromaDemo",
            dependencies: [
                "Chroma",
                "ChromaBase46Themes",
            ]
        ),
        .executableTarget(
            name: "Ca",
            dependencies: [
                "Chroma",
                "ChromaBase46Themes",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Configuration", package: "swift-configuration"),
            ]
        ),
        .executableTarget(
            name: "ChromaBenchmarks",
            dependencies: [
                "Chroma",
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/ChromaBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
    ]
)
