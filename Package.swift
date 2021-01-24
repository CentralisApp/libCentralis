// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "libCentralis",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "libCentralis", targets: ["libCentralis"]),
    ],
    targets: [
        .target(name: "libCentralis", path: "libCentralis"),
    ]
)
