// swift-tools-version:4.2

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
    .library(name: "HtmlCssSupport", targets: ["HtmlCssSupport"]),
    .library(name: "HtmlTestSupport", targets: ["HtmlTestSupport"]),
    .library(name: "HtmlPlainTextPrint", targets: ["HtmlPlainTextPrint"]),
    .library(name: "HtmlPrettyPrint", targets: ["HtmlPrettyPrint"]),
    .library(name: "HttpPipeline", targets: ["HttpPipeline"]),
//    .executable(name: "HttpPipelineExample", targets: ["HttpPipelineExample"]),
    .library(name: "HttpPipelineHtmlSupport", targets: ["HttpPipelineHtmlSupport"]),
    .library(name: "HttpPipelineTestSupport", targets: ["HttpPipelineTestSupport"]),
    .library(name: "UrlFormEncoding", targets: ["UrlFormEncoding"]),
    .library(name: "View", targets: ["View"])
    ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("a027f0b")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .revision("86f36c9")),
    .package(url: "https://github.com/pointfreeco/swift-html", .revision("0.1.3")),
    .package(url: "https://github.com/apple/swift-nio.git", from: "1.8.0"),
    .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", .exact("1.0.4")),
  ],
  targets: [
    .target(name: "ApplicativeRouter", dependencies: ["Either", "Optics", "Prelude", "UrlFormEncoding"]),
    .testTarget(name: "ApplicativeRouterTests", dependencies: ["ApplicativeRouter", "Optics", "SnapshotTesting", "HttpPipelineTestSupport"]),

    .target(name: "ApplicativeRouterHttpPipelineSupport",
            dependencies: ["ApplicativeRouter", "HttpPipeline", "Prelude"]),
    .testTarget(name: "ApplicativeRouterHttpPipelineSupportTests",
                dependencies: ["ApplicativeRouterHttpPipelineSupport", "HttpPipelineTestSupport", "SnapshotTesting"]),

    .target(name: "Css", dependencies: ["Either", "Prelude"]),
    .testTarget(name: "CssTests", dependencies: ["Css", "CssTestSupport"]),

    .target(name: "CssReset", dependencies: ["Css"]),
    .testTarget(name: "CssResetTests", dependencies: ["CssReset", "CssTestSupport"]),

    .target(name: "CssTestSupport", dependencies: ["Css", "SnapshotTesting"]),

    .target(name: "HtmlCssSupport", dependencies: ["Css", "Html"]),
    .testTarget(name: "HtmlCssSupportTests", dependencies: ["HtmlCssSupport", "HtmlPrettyPrint", "CssTestSupport", "HtmlTestSupport"]),

    .target(name: "HtmlPlainTextPrint", dependencies: ["Html", "Prelude"]),
    .testTarget(name: "HtmlPlainTextPrintTests", dependencies: ["HtmlPlainTextPrint", "Css", "Html", "HtmlCssSupport", "HtmlPrettyPrint", "SnapshotTesting"]),

    .target(name: "HtmlPrettyPrint", dependencies: ["Html"]),
    .testTarget(name: "HtmlPrettyPrintTests", dependencies: ["Css", "HtmlCssSupport", "HtmlPrettyPrint", "HtmlTestSupport", "SnapshotTesting"]),

    .target(name: "HtmlTestSupport", dependencies: ["HtmlPrettyPrint", "SnapshotTesting"]),

    .target(name: "HttpPipeline",
            dependencies: ["Cryptor", "Html", "NIO", "NIOHTTP1", "Prelude", "Optics"]),
//    .target(name: "HttpPipelineExample",
//            dependencies: ["HttpPipeline", "HttpPipelineHtmlSupport"]),
    .testTarget(name: "HttpPipelineTests",
                dependencies: ["HttpPipeline", "SnapshotTesting", "HttpPipelineTestSupport"]),

    .target(name: "HttpPipelineHtmlSupport", dependencies: ["Html", "HttpPipeline", "View"]),
    .testTarget(name: "HttpPipelineHtmlSupportTests", dependencies: ["HttpPipelineHtmlSupport", "SnapshotTesting"]),

    .target(name: "HttpPipelineTestSupport", dependencies: ["HttpPipeline", "Html", "SnapshotTesting"]),

    .target(name: "UrlFormEncoding", dependencies: ["Prelude", "Optics"]),
    .testTarget(name: "UrlFormEncodingTests", dependencies: ["UrlFormEncoding", "SnapshotTesting"]),

    .target(name: "View", dependencies: ["Html", "Prelude"]),
    ]
)
