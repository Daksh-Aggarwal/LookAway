// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LookAway",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "EyeAppMac", targets: ["EyeAppMac"])
    ],
    targets: [
        .executableTarget(
            name: "EyeAppMac",
            path: "Sources/EyeAppMac"
        )
    ]
)
