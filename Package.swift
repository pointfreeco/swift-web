// swift-tools-version:5.10

import PackageDescription

let package = Package(
  name: "swift-web",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .watchOS(.v6),
    .tvOS(.v13),
  ],
  products: [
    .library(name: "HttpPipeline", targets: ["HttpPipeline"]),
    .library(name: "HttpPipelineHtmlSupport", targets: ["HttpPipelineHtmlSupport"]),
    .library(name: "HttpPipelineTestSupport", targets: ["HttpPipelineTestSupport"]),
    .library(name: "UrlFormEncoding", targets: ["UrlFormEncoding"]),
    .library(name: "View", targets: ["View"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-html", revision: "be9d301"),
    .package(url: "https://github.com/pointfreeco/swift-prelude", revision: "da5ead2"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.3"),
    .package(url: "https://github.com/apple/swift-crypto.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.64.0"),
    .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.22.0"),
    .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "HttpPipeline",
      dependencies: [
        .product(name: "NIO", package: "swift-nio"),
        .product(name: "NIOHTTP1", package: "swift-nio"),
        .product(name: "NIOHTTPTypes", package: "swift-nio-extras"),
        .product(name: "NIOHTTPTypesHTTP1", package: "swift-nio-extras"),
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "Crypto", package: "swift-crypto"),
        .product(name: "Cryptor", package: "BlueCryptor"),
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
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
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
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ]
    ),

    .target(
      name: "HttpPipelineTestSupport",
      dependencies: [
        "HttpPipeline",
        .product(name: "Html", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
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
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
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
