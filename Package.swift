// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "RateLimitedCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "RateLimitedCore", targets: ["RateLimitedCore"])
    ],
    targets: [
        .target(
            name: "RateLimitedCore",
            path: "RateLimited/Core"
        ),
        .testTarget(
            name: "RateLimitedCoreTests",
            dependencies: ["RateLimitedCore"],
            path: "Tests/RateLimitedCoreTests"
        )
    ]
)
