// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyFinalChessFramework",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "MyFinalChessFramework",
            targets: ["MyFinalChessFramework"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MyFinalChessFramework",
            dependencies: []),
        .testTarget(
            name: "MyFinalChessFrameworkTests",
            dependencies: ["MyFinalChessFramework"]),
    ]
)
