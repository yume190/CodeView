// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodeView",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "CodeView",
            targets: ["CodeView"]),
    ],
    dependencies: [
         .package(url: "https://github.com/migueldeicaza/SwiftTerm", from: "1.0.0"),
         .package(url: "https://github.com/kylef/PathKit", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "CodeView",
            dependencies: [
                "PathKit",
                "SwiftTerm",
            ],
            resources: [
                .copy("highlights"),
            ]),
    ]
)
