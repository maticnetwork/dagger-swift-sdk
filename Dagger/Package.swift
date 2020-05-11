// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dagger",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Dagger",
            targets: ["Dagger"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/aciidb0mb3r/SwiftMQTT",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "Dagger",
             dependencies: ["SwiftMQTT"]),
        .testTarget(
            name: "DaggerTests",
            dependencies: ["Dagger"]),
    ]
)
