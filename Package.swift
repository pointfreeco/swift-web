// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "Web",
  products: [
    .library(name: "ApplicativeRouter", targets: ["ApplicativeRouter"]),
    .library(name: "ApplicativeRouterHttpPipelineSupport",
             targets: ["ApplicativeRouterHttpPipelineSupport"]),
    .library(name: "Css", targets: ["Css"]),
    .library(name: "CssReset", targets: ["CssReset"]),
    .library(name: "CssTestSupport", targets: ["CssTestSupport"]),
    .library(name: "Html", targets: ["Html"]),
    .library(name: "HtmlCssSupport", targets: ["HtmlCssSupport"]),
    .library(name: "HtmlTestSupport", targets: ["HtmlTestSupport"]),
    .library(name: "HtmlPrettyPrint", targets: ["HtmlPrettyPrint"]),
    .library(name: "HttpPipeline", targets: ["HttpPipeline"]),
    .library(name: "HttpPipelineHtmlSupport", targets: ["HttpPipelineHtmlSupport"]),
    .library(name: "HttpPipelineTestSupport", targets: ["HttpPipelineTestSupport"]),
    .library(name: "MediaType", targets: ["MediaType"]),
    .library(name: "UrlFormEncoding", targets: ["UrlFormEncoding"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("b70de46")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .revision("c510e7d")),
    .package(url: "https://github.com/bkase/DoctorPretty.git", .exact("0.3.0")),
    .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", .exact("0.8.21"))
  ],
  targets: [
    .target(name: "ApplicativeRouter", dependencies: ["Either", "Optics", "Prelude", "UrlFormEncoding"]),
    .testTarget(name: "ApplicativeRouterTests", dependencies: ["ApplicativeRouter", "Deriving", "Optics", "SnapshotTesting", "HttpPipelineTestSupport"]),

    .target(name: "ApplicativeRouterHttpPipelineSupport",
            dependencies: ["ApplicativeRouter", "HttpPipeline", "Prelude"]),
    .testTarget(name: "ApplicativeRouterHttpPipelineSupportTests",
                dependencies: ["ApplicativeRouterHttpPipelineSupport", "HttpPipelineTestSupport", "SnapshotTesting"]),

    .target(name: "Css", dependencies: ["Either", "Prelude"]),
    .testTarget(name: "CssTests", dependencies: ["Css", "CssTestSupport"]),

    .target(name: "CssReset", dependencies: ["Css"]),
    .testTarget(name: "CssResetTests", dependencies: ["CssReset", "CssTestSupport"]),

    .target(name: "CssTestSupport", dependencies: ["Css", "SnapshotTesting"]),

    .target(name: "Html", dependencies: ["MediaType", "NonEmpty", "Prelude"]),
    .testTarget(name: "HtmlTests", dependencies: ["Html", "HtmlCssSupport", "HtmlPrettyPrint", "HtmlTestSupport"]),

    .target(name: "HtmlCssSupport", dependencies: ["Css", "Html"]),
    .testTarget(name: "HtmlCssSupportTests", dependencies: ["HtmlCssSupport", "HtmlPrettyPrint", "CssTestSupport", "HtmlTestSupport"]),

    .target(name: "HtmlPrettyPrint", dependencies: ["DoctorPretty", "Html"]),
    .testTarget(name: "HtmlPrettyPrintTests", dependencies: ["HtmlPrettyPrint", "SnapshotTesting"]),

    .target(name: "HtmlTestSupport", dependencies: ["HtmlPrettyPrint", "SnapshotTesting"]),

    .target(name: "HttpPipeline",
            dependencies: ["Cryptor", "MediaType", "Prelude", "Optics"]),
    .testTarget(name: "HttpPipelineTests",
                dependencies: ["Deriving", "HttpPipeline", "SnapshotTesting", "HttpPipelineTestSupport"]),

    .target(name: "HttpPipelineHtmlSupport", dependencies: ["Html", "HttpPipeline"]),
    .testTarget(name: "HttpPipelineHtmlSupportTests", dependencies: ["HttpPipelineHtmlSupport", "SnapshotTesting"]),

    .target(name: "HttpPipelineTestSupport", dependencies: ["HttpPipeline", "MediaType", "SnapshotTesting"]),

    .target(name: "MediaType", dependencies: []),

    .target(name: "UrlFormEncoding", dependencies: ["Prelude"]),
    .testTarget(name: "UrlFormEncodingTests", dependencies: ["UrlFormEncoding", "SnapshotTesting"]),
  ]
)
