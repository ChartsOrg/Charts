// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "DGCharts",
    platforms: [
          .iOS(.v12),
          .tvOS(.v12),
          .macOS(.v10_12),
    ],
    products: [
        .library(
            name: "DGCharts",
            targets: ["DGCharts"]),
        .library(
            name: "DGChartsDynamic",
            type: .dynamic,
            targets: ["DGCharts"])
    ],
    targets: [
        .target(
            name: "DGCharts",
            path: "Source/Charts"
        )
    ],
    swiftLanguageVersions: [.v5]
)
