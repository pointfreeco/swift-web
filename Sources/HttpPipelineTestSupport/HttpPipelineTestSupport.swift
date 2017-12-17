import Foundation
import HttpPipeline
import MediaType
import Prelude
import SnapshotTesting
import XCTest

extension Application {
  var isOther: Bool {
    return !["javascript", "json", "xml", "x-www-form-url-encoded"].contains(self.rawValue)
  }
}

extension Response: Snapshot {
  public typealias Format = String

  public static var snapshotPathExtension: String? {
    return "Response.txt"
  }

  public var snapshotFormat: String {
    let lines = ["Status \(self.status.rawValue) \(String(describing: self.status).formattedStatusString())"]
      + self.headers.map { $0.description }.sorted()
    let top = lines.joined(separator: "\n")

    let contentMediaType: MediaType? = self.headers
      .flatMap {
        if case let .contentType(mediaType) = $0 {
          return mediaType
        }
        return nil
    }.first

    if contentMediaType?.application?.isOther == .some(true) || contentMediaType?.isText == .some(true) {
      // todo: use proper encoding when available
      return top + "\n\n\(String(decoding: self.body, as: UTF8.self))\n"
    }
    return top
  }
}

extension Conn: Snapshot {
  public var snapshotFormat: String {
    let indent = "  "
    return """
▿ Step
  \(Step.self)

▿ Request
\(prefixLines(with: indent) <| self.request.snapshotFormat)

▿ Response
\(prefixLines(with: indent) <| self.response.snapshotFormat)
"""
  }

  public static var snapshotPathExtension: String? {
    return "Conn.txt"
  }
}

// TODO: move to snapshot-testing
extension URLRequest: Snapshot {

  public var snapshotFormat: String {
    let headers = (self.allHTTPHeaderFields ?? [:])
      .map { key, value in "\(key): \(value)" }
      .sorted()

    // NB: `absoluteString` is necessary because of https://github.com/apple/swift-corelibs-foundation/pull/1312
    let lines = ["\(self.httpMethod ?? "GET") \((self.url?.absoluteString).map(String.init(describing:)) ?? "?")"]
      + headers
    let top = lines.joined(separator: "\n")

    let body = self.httpBody.map { String(decoding: $0, as: UTF8.self) }
      ?? "(Data, \(self.httpBody?.count ?? 0) bytes)"

    return """
\(top)

\(body)
"""
  }

  public static var snapshotPathExtension: String? {
    return "URLRequest.txt"
  }
}

// TODO: move to prelude
extension Sequence {
  fileprivate func sorted<C: Comparable>(by keyPath: KeyPath<Element, C>) -> [Element] {
    return self.sorted { lhs, rhs in
      lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
    }
  }
}

private func prefixLines(with prefix: String) -> (String) -> String {
  return { string in
    string
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map { $0.isEmpty ? "\($0)" : "\(prefix)\($0)" }
      .joined(separator: "\n")
  }
}

extension String {
  fileprivate func formattedStatusString() -> String {
    return self
      .lazy
      .map(String.init)
      .reduce("") { (string: String, character: String) -> String in
        character.uppercased() == character
          ? string + " " + character
          : string + character
      }
      .uppercased()
  }
}
