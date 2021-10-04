// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "swift-web",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "ApplicativeRouter", targets: ["ApplicativeRouter"]),
    .library(
      name: "ApplicativeRouterHttpPipelineSupport",
      targets: ["ApplicativeRouterHttpPipelineSupport"]
    ),
    .library(name: "Css", targets: ["Css"]),
    .library(name: "CssReset", targets: ["CssReset"]),
    .library(name: "CssTestSupport", targets: ["CssTestSupport"]),
    .library(name: "HtmlCssSupport", targets: ["HtmlCssSupport"]),
    .library(name: "HtmlPlainTextPrint", targets: ["HtmlPlainTextPrint"]),
    .library(name: "HttpPipeline", targets: ["HttpPipeline"]),
    .library(name: "HttpPipelineHtmlSupport", targets: ["HttpPipelineHtmlSupport"]),
    .library(name: "HttpPipelineTestSupport", targets: ["HttpPipelineTestSupport"]),
    .library(name: "UrlFormEncoding", targets: ["UrlFormEncoding"]),
    .library(name: "View", targets: ["View"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-html", from: "0.4.0"),
    .package(url: "https://github.com/pointfreeco/swift-prelude", .revision("7ff9911")),
    .package(
      name: "SnapshotTesting",
      url: "https://github.com/pointfreeco/swift-snapshot-testing",
      from: "1.9.0"
    ),
    .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.0.0"),
    .package(
      name: "Cryptor",
      url: "https://github.com/IBM-Swift/BlueCryptor.git",
      from: "1.0.0"
    ),
  ],
  targets: [
    .target(
      name: "ApplicativeRouter",
      dependencies: [
        "UrlFormEncoding",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Optics", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),
    .testTarget(
      name: "ApplicativeRouterTests",
      dependencies: [
        "ApplicativeRouter",
        "HttpPipelineTestSupport",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      exclude: [
        "__Snapshots__",
      ]
    ),

    .target(
      name: "ApplicativeRouterHttpPipelineSupport",
      dependencies: [
        "ApplicativeRouter",
        "HttpPipeline",
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),
    .testTarget(
      name: "ApplicativeRouterHttpPipelineSupportTests",
      dependencies: [
        "ApplicativeRouterHttpPipelineSupport",
        "HttpPipelineTestSupport",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      exclude: [
        "__Snapshots__",
      ]
    ),

    .target(
      name: "Css",
      dependencies: [
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),
    .testTarget(
      name: "CssTests",
      dependencies: [
        "Css",
        "CssTestSupport",
      ],
      exclude: [
        "__Snapshots__",
      ]
    ),

    .target(
      name: "CssReset",
      dependencies: ["Css"]
    ),
    .testTarget(
      name: "CssResetTests",
      dependencies: ["CssReset", "CssTestSupport"],
      exclude: [
        "__Snapshots__",
      ]
    ),

    .target(
      name: "CssTestSupport",
      dependencies: [
        "Css",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ]
    ),

    .target(
      name: "HtmlCssSupport",
      dependencies: [
        "Css",
        .product(name: "Html", package: "swift-html"),
      ]
    ),
    .testTarget(
      name: "HtmlCssSupportTests",
      dependencies: [
        "CssTestSupport",
        "HtmlCssSupport",
        .product(name: "HtmlSnapshotTesting", package: "swift-html"),
      ]
    ),

    .target(
      name: "HtmlPlainTextPrint",
      dependencies: [
        .product(name: "Html", package: "swift-html"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),
    .testTarget(
      name: "HtmlPlainTextPrintTests",
      dependencies: [
        "Css",
        "HtmlPlainTextPrint",
        "HtmlCssSupport",
        .product(name: "Html", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      exclude: [
        "__Snapshots__",
      ]
    ),

    .target(
      name: "HttpPipeline",
      dependencies: [
        .product(name: "NIO", package: "swift-nio"),
        .product(name: "NIOHTTP1", package: "swift-nio"),
        .product(name: "NIOHTTPCompression", package: "swift-nio-extras"),
        .product(name: "Crypto", package: "swift-crypto"),
        .product(name: "Cryptor", package: "Cryptor"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "Optics", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),
    .testTarget(
      name: "HttpPipelineTests",
      dependencies: [
        "HttpPipeline",
        "HttpPipelineTestSupport",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      exclude: [
        "__Snapshots__",
      ]
    ),

    .target(
      name: "HttpPipelineHtmlSupport",
      dependencies: [
        "HttpPipeline",
        "View",
        .product(name: "Html", package: "swift-html"),
      ]
    ),
    .testTarget(
      name: "HttpPipelineHtmlSupportTests",
      dependencies: [
        "HttpPipelineHtmlSupport",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ]
    ),

    .target(
      name: "HttpPipelineTestSupport",
      dependencies: [
        "HttpPipeline",
        .product(name: "Html", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ]
    ),

    .target(
      name: "UrlFormEncoding",
      dependencies: [
        .product(name: "Optics", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),
    .testTarget(
      name: "UrlFormEncodingTests",
      dependencies: [
        "UrlFormEncoding",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      exclude: [
        "__Snapshots__",
      ]
    ),

    .target(
      name: "View",
      dependencies: [
        .product(name: "Html", package: "swift-html"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),
  ]
)
