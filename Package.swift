// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "Web",
  products: [
    .library(name: "ApplicativeRouter", targets: ["ApplicativeRouter"]),
    .library(name: "Css", targets: ["Css"]),
    .library(name: "CssReset", targets: ["CssReset"]),
    .library(name: "CssTestSupport", targets: ["CssTestSupport"]),
    .library(name: "Html", targets: ["Html"]),
    .library(name: "HtmlCssSupport", targets: ["HtmlCssSupport"]),
    .library(name: "HtmlTestSupport", targets: ["HtmlTestSupport"]),
    .library(name: "HtmlPrettyPrint", targets: ["HtmlPrettyPrint"]),
    .library(name: "HttpPipeline", targets: ["HttpPipeline"]),
    .library(name: "HttpPipelineHtmlSupport", targets: ["HttpPipelineHtmlSupport"]),
    .library(name: "MediaType", targets: ["MediaType"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("5bb9f1a")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .revision("b06511e")),
    .package(url: "https://github.com/bkase/DoctorPretty.git", .exact("0.3.0")),
  ],
  targets: [
    .target(name: "ApplicativeRouter", dependencies: ["Prelude"]),
    .testTarget(name: "ApplicativeRouterTests", dependencies: ["ApplicativeRouter"]),

    .target(name: "Css", dependencies: ["Prelude", "Either"]),
    .testTarget(name: "CssTests", dependencies: ["Css", "CssTestSupport"]),

    .target(name: "CssReset", dependencies: ["Css"]),
    .testTarget(name: "CssResetTests", dependencies: ["CssReset", "CssTestSupport"]),

    .target(name: "CssTestSupport", dependencies: ["Css", "SnapshotTesting"]),

    .target(name: "Html", dependencies: ["MediaType", "Prelude"]),
    .testTarget(name: "HtmlTests", dependencies: ["Html", "HtmlCssSupport", "HtmlPrettyPrint", "HtmlTestSupport"]),

    .target(name: "HtmlCssSupport", dependencies: ["Css", "Html"]),
    .testTarget(name: "HtmlCssSupportTests", dependencies: ["HtmlCssSupport", "HtmlPrettyPrint", "CssTestSupport", "HtmlTestSupport"]),

    .target(name: "HtmlPrettyPrint", dependencies: ["DoctorPretty", "Html"]),
    .testTarget(name: "HtmlPrettyPrintTests", dependencies: ["HtmlPrettyPrint", "SnapshotTesting"]),

    .target(name: "HtmlTestSupport", dependencies: ["HtmlPrettyPrint", "SnapshotTesting"]),

    .target(name: "HttpPipeline", dependencies: ["MediaType", "Prelude"]),
    .testTarget(name: "HttpPipelineTests", dependencies: ["HttpPipeline"]),

    .target(name: "HttpPipelineHtmlSupport", dependencies: ["Html", "HttpPipeline"]),
    .testTarget(name: "HttpPipelineHtmlSupportTests", dependencies: ["HttpPipelineHtmlSupport", "SnapshotTesting"]),

    .target(name: "MediaType", dependencies: []),
  ]
)
