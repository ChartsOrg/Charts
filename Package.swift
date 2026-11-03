// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "DGCharts",
    platforms: [
          .iOS(.v18),
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
    swiftLanguageModes: [.v5]
)