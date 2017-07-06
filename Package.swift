// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "swift-web",
  products: [
    .library(name: "ApplicativeRouter", targets: ["ApplicativeRouter"]),
    .library(name: "Css", targets: ["Css"]),
    .library(name: "Html", targets: ["Html"]),
    .library(name: "HtmlCssSupport", targets: ["HtmlCssSupport"]),
    .library(name: "HttpPipeline", targets: ["HttpPipeline"]),
    .library(name: "HttpPipelineHtmlSupport", targets: ["HttpPipelineHtmlSupport"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("d242e07")),
  ],
  targets: [
    .target(name: "ApplicativeRouter", dependencies: ["Prelude"]),
    .testTarget(name: "ApplicativeRouterTests", dependencies: ["ApplicativeRouter"]),

    .target(name: "Css", dependencies: ["Prelude", "Either"]),
    .testTarget(name: "CssTests", dependencies: ["Css"]),

    .target(name: "Html", dependencies: ["Prelude"]),
    .testTarget(name: "HtmlTests", dependencies: ["Html", "HtmlCssSupport"]),

    .target(name: "HtmlCssSupport", dependencies: ["Css", "Html"]),
    .testTarget(name: "HtmlCssSupportTests", dependencies: ["HtmlCssSupport"]),

    .target(name: "HttpPipeline", dependencies: ["Prelude"]),
    .testTarget(name: "HttpPipelineTests", dependencies: ["HttpPipeline"]),

    .target(name: "HttpPipelineHtmlSupport", dependencies: ["Html", "HttpPipeline"]),
    .testTarget(name: "HttpPipelineHtmlSupportTests", dependencies: ["HttpPipelineHtmlSupport"]),
  ]
)
