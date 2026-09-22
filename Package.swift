// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LookAway",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "LookAway", targets: ["LookAway"])
    ],
    targets: [
        .executableTarget(
            name: "LookAway",
            path: "Sources/LookAway"
        )
    ]
)
