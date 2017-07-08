// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "swift-web",
  products: [
    .library(name: "ApplicativeRouter", targets: ["ApplicativeRouter"]),
    .library(name: "Css", targets: ["Css"]),
    .library(name: "CssReset", targets: ["CssReset"]),
    .library(name: "Html", targets: ["Html"]),
    .library(name: "HtmlCssSupport", targets: ["HtmlCssSupport"]),
    .library(name: "HtmlPrettyPrint", targets: ["HtmlPrettyPrint"]),
    .library(name: "HttpPipeline", targets: ["HttpPipeline"]),
    .library(name: "HttpPipelineHtmlSupport", targets: ["HttpPipelineHtmlSupport"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("d242e07")),
    .package(url: "https://github.com/bkase/DoctorPretty.git", .exact("0.3.0")),
  ],
  targets: [
    .target(name: "ApplicativeRouter", dependencies: ["Prelude"]),
    .testTarget(name: "ApplicativeRouterTests", dependencies: ["ApplicativeRouter"]),

    .target(name: "Css", dependencies: ["Prelude", "Either"]),
    .testTarget(name: "CssTests", dependencies: ["Css"]),

    .target(name: "CssReset", dependencies: ["Css"]),
    .testTarget(name: "CssResetTests", dependencies: ["CssReset"]),

    .target(name: "Html", dependencies: ["Prelude"]),
    .testTarget(name: "HtmlTests", dependencies: ["Html", "HtmlCssSupport", "HtmlPrettyPrint"]),

    .target(name: "HtmlCssSupport", dependencies: ["Css", "Html"]),
    .testTarget(name: "HtmlCssSupportTests", dependencies: ["HtmlCssSupport", "HtmlPrettyPrint"]),

    .target(name: "HtmlPrettyPrint", dependencies: ["DoctorPretty", "Html"]),
    .testTarget(name: "HtmlPrettyPrintTests", dependencies: ["HtmlPrettyPrint"]),

    .target(name: "HttpPipeline", dependencies: ["Prelude"]),
    .testTarget(name: "HttpPipelineTests", dependencies: ["HttpPipeline"]),

    .target(name: "HttpPipelineHtmlSupport", dependencies: ["Html", "HttpPipeline"]),
    .testTarget(name: "HttpPipelineHtmlSupportTests", dependencies: ["HttpPipelineHtmlSupport"]),
  ]
)
