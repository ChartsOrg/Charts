// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Charts",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v10_11),
    ],
    products: [
        .library(
            name: "Charts",
            targets: ["Charts"]
        ),
        .library(
            name: "ChartsDynamic",
            type: .dynamic,
            targets: ["Charts"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", .branch("main")),
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.1"),
    ],
    targets: [
        .target(
            name: "Charts",
            dependencies: [.product(name: "Algorithms", package: "swift-algorithms")]
        ),
        .testTarget(
            name: "ChartsTests",
            dependencies: ["Charts", "SnapshotTesting"],
            exclude: ["__Snapshots__"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
