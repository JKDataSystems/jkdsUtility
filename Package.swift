// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "jkdsUtility",
    platforms: [.iOS(.v15), .macOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "jkdsUtility",
            targets: ["jkdsUtility"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.11.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "jkdsUtility",
            dependencies: [
                "Alamofire"
            ]
        ),
        .testTarget(
            name: "jkdsUtilityTests",
            dependencies: [
                "jkdsUtility"
            ]
        )

    ]    
)
