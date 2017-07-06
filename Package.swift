// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "swift-web",
  products: [
    .library(name: "HTML", targets: ["HTML"]),
    .library(name: "CSS", targets: ["CSS"]),
    .library(name: "ApplicativeRouter", targets: ["ApplicativeRouter"]),
    .library(name: "HTTPPipeline", targets: ["HTTPPipeline"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("d242e07")),
  ],
  targets: [
    .target(name: "HTML", dependencies: ["CSS", "Prelude"]),
    .testTarget(name: "HTMLTests", dependencies: ["HTML"]),

    .target(name: "CSS", dependencies: ["Prelude", "Either"]),
    .testTarget(name: "CSSTests", dependencies: ["CSS"]),

    .target(name: "ApplicativeRouter", dependencies: ["Prelude"]),
    .testTarget(name: "ApplicativeRouterTests", dependencies: ["ApplicativeRouter"]),

    .target(name: "HTTPPipeline", dependencies: ["Prelude", "HTML"]),
    .testTarget(name: "HTTPPipelineTests", dependencies: ["HTTPPipeline"]),
  ]
)
