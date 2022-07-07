// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Charts",
    platforms: [
          .iOS(.v12),
          .tvOS(.v12),
          .macOS(.v10_12),
    ],
    products: [
        .library(
            name: "Charts",
            targets: ["Charts"]),
        .library(
            name: "ChartsDynamic",
            type: .dynamic,
            targets: ["Charts"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Charts",
            dependencies: [.product(name: "Algorithms", package: "swift-algorithms")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
