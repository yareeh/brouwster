// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Brouwster",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "BrouwsterCore"),
        // Settings app the user opens.
        .executableTarget(name: "Brouwster", dependencies: ["BrouwsterCore"]),
        // Background app registered as the default browser; embedded in Brouwster.app.
        .executableTarget(name: "BrouwsterRouter", dependencies: ["BrouwsterCore"]),
        .testTarget(name: "BrouwsterCoreTests", dependencies: ["BrouwsterCore"]),
    ]
)
