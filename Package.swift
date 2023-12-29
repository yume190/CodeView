// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CodeView",
  platforms: [
    .macOS(.v11)
  ],
  products: [
    .library(name: "TerminalUI", targets: ["TerminalUI"]),
    .library(name: "CodeViewMonaco", targets: ["CodeViewMonaco"]),
    .library(name: "CodeViewHighlights", targets: ["CodeViewHighlights"]),
  ],
  dependencies: [
    .package(url: "https://github.com/migueldeicaza/SwiftTerm", from: "1.0.0"),
    .package(url: "https://github.com/kylef/PathKit", from: "1.0.0"),
  ],
  targets: [
    .target(name: "Workspace", dependencies: ["PathKit"]),
    .target(
      name: "TerminalUI",
      dependencies: [
        "Workspace",
        "PathKit",
        "SwiftTerm",
      ]
    ),
    .target(
      name: "CodeViewHighlights",
      dependencies: [
        "Workspace",
        "PathKit",
      ],
      resources: [
        .copy("highlights"),
      ]),
    .target(
      name: "CodeViewMonaco",
      dependencies: [
        "Workspace",
        "PathKit",
      ],
      resources: [
        .copy("monaco-editor"),
      ]),
  ]
)
