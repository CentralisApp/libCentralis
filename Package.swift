// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "libCentralis",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(name: "libCentralis", targets: ["libCentralis"]),
    ],
    targets: [
        .target(name: "libCentralis", path: "libCentralis"),
    ]
)
