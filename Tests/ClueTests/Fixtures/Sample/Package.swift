// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Sample",
    products: [
        .library(name: "Sample", targets: ["Sample"]),
        .executable(name: "sample-cli", targets: ["sample-cli"]),
    ],
    targets: [
        .target(name: "Sample"),
        .executableTarget(name: "sample-cli", dependencies: ["Sample"]),
    ]
)
