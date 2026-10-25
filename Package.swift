// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Brouwster",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "BrouwsterCore"),
        .executableTarget(name: "Brouwster", dependencies: ["BrouwsterCore"]),
        .testTarget(name: "BrouwsterCoreTests", dependencies: ["BrouwsterCore"]),
    ]
)
