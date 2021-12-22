// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Clue",
    products: [
        .executable(name: "clue-cli", targets: ["clue-cli"]),
        .library(name: "Clue", targets: ["Clue"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/indexstore-db",
            .revision("swift-5.5.2-RELEASE")
        ),
        .package(
            url: "https://github.com/dduan/Pathos",
            from: "0.4.2"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.2"
        ),
    ],
    targets: [
        .executableTarget(
            name: "clue-cli",
            dependencies: [
                .target(name: "Clue"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "Clue",
            dependencies: [
                .product(name: "IndexStoreDB", package: "indexstore-db"),
                .product(name: "Pathos", package: "Pathos"),
            ]
        ),
        .testTarget(
            name: "ClueTests",
            dependencies: [
                "Clue",
                "Pathos",
            ],
            exclude: ["Fixtures"]
        ),
    ]
)
