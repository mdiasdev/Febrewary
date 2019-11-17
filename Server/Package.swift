// swift-tools-version:4.2
// Generated automatically by Perfect Assistant
// Date: 2019-10-13 19:10:15 +0000
import PackageDescription

let package = Package(
	name: "FebrewaryServer",
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/SwiftORM/Postgres-StORM.git", "3.1.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-Crypto.git", "3.2.0"..<"4.0.0"),
		.package(url: "https://github.com/IBM-Swift/Configuration.git", "3.0.3"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-PostgreSQL.git", "3.0.0"..<"4.0.0")
	],
	targets: [
		.target(name: "FebrewaryServerApp", dependencies: ["FebrewaryServerLib", "PerfectHTTPServer", "PostgresStORM"]),
		.target(name: "FebrewaryServerLib", dependencies: ["PerfectHTTPServer", "PostgresStORM", "PerfectCrypto", "Configuration"]),
		.testTarget(name: "FebrewaryServerLibTests", dependencies: ["FebrewaryServerLib", "PerfectHTTPServer", "PostgresStORM", "PerfectCrypto", "Configuration"])
	]
)