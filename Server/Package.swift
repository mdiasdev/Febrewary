// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FebrewaryServer",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
        .package(url: "https://github.com/SwiftORM/Postgres-StORM.git", from: "3.1.0")
        // TODO: Swagger docs https://github.com/mczachurski/Swiftgger
        // TODO: move server values out https://github.com/IBM-Swift/Configuration.git
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "FebrewaryServerApp",
            dependencies: ["FebrewaryServerLib", "PerfectHTTPServer", "PostgresStORM"]),
        .target(name: "FebrewaryServerLib",
                dependencies: ["PerfectHTTPServer", "PostgresStORM"]),
        .testTarget(
            name: "FebrewaryServerLibTests",
            dependencies: ["FebrewaryServerLib", "PerfectHTTPServer", "PostgresStORM"]),
        ]
)
