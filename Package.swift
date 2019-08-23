// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Charts",
    platforms: [
       .iOS(.v8),
       .tvOS(.v9),
       .macOS(.v10_11),
    ],
    products: [
        .library(name: "Charts", type: .dynamic, targets: ["Charts"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Charts", dependencies: [], path: "./Source", publicHeadersPath: "./Source/Supporting Files")
    ]
)
