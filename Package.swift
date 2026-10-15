// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignPilotSDK",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "DesignPilotSDK",
            targets: ["DesignPilotSDK"]
        ),
        .library(
            name: "DesignPilotEngine",
            targets: ["DesignPilotEngine"]
        ),
        .executable(
            name: "designpilot",
            targets: ["designpilot"]
        ),
    ],
    targets: [
        .target(
            name: "DesignPilotSDK",
            dependencies: [],
            path: "Sources/DesignPilotSDK"
        ),
        .target(
            name: "DesignPilotEngine",
            dependencies: ["DesignPilotSDK"],
            path: "Sources/DesignPilotEngine"
        ),
        .executableTarget(
            name: "designpilot",
            dependencies: ["DesignPilotEngine", "DesignPilotSDK"],
            path: "Sources/designpilot"
        ),
        .testTarget(
            name: "DesignPilotSDKTests",
            dependencies: ["DesignPilotSDK", "DesignPilotEngine"],
            path: "Tests/DesignPilotSDKTests"
        ),
    ]
)
