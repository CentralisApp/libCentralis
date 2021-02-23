// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "libCentralis",
    products: [
        .library(name: "libCentralis", targets: ["libCentralis"]),
    ],
    targets: [
        .target(name: "libCentralis", path: "libCentralis"),
    ]
)
