// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ThanosLight",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ThanosLight", targets: ["ThanosLight"]),
        .executable(name: "ThanosLightRecovery", targets: ["ThanosLightRecovery"])
    ],
    targets: [
        .executableTarget(
            name: "ThanosLight",
            resources: [.process("Resources")]
        ),
        .executableTarget(name: "ThanosLightRecovery"),
        .testTarget(name: "ThanosLightTests", dependencies: ["ThanosLight"])
    ]
)
