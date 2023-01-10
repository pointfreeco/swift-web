import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Html
import HttpPipeline
import Optics
import Prelude
import SnapshotTesting
import XCTest

extension Application {
  var isOther: Bool {
    return !["javascript", "json", "xml", "x-www-form-url-encoded"].contains(self.rawValue)
  }
}

extension Snapshotting where Value == Conn<ResponseEnded, Data>, Format == String {
  public static let conn = SimplySnapshotting.lines.pullback { (conn: Conn<ResponseEnded, Data>) in
    let request = try await Snapshotting<URLRequest, String>.raw.snapshot { conn.request }
    let response = try await Snapshotting<Response, String>.response.snapshot { conn.response }
    return request + "\n\n" + response
  } |> \.pathExtension .~ "Conn.txt"
}

extension Snapshotting where Value == Response, Format == String {
  public static let response = SimplySnapshotting.lines.pullback { (response: Response) in
    let lines = ["\(response.status.rawValue) \(response.status.description)"]
      + response.headers.map { $0.description }.sorted()
    let top = lines.joined(separator: "\n")

    let isApplicationOrText = response.headers
      .first(where: { $0.name == "Content-Type" })
      .map { $0.value.hasPrefix("application/") || $0.value.hasPrefix("text/") }
      ?? false

    if isApplicationOrText {
      // todo: use proper encoding when available
      return top + "\n\n\(String(decoding: response.body, as: UTF8.self))\n"
    }
    return top
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
