import Foundation
import Html
import HttpPipeline
import Prelude
import SnapshotTesting
import XCTest

extension Application {
  var isOther: Bool {
    return !["javascript", "json", "xml", "x-www-form-url-encoded"].contains(self.rawValue)
  }
}

extension Strategy where A == Conn<ResponseEnded, Data>, B == String {
  public static var conn: Strategy<Conn<ResponseEnded, Data>, String> {
    var conn = SimpleStrategy.lines.asyncPullback { (conn: Conn<ResponseEnded, Data>) in
      Async { callback in
        Strategy<URLRequest, String>.request.snapshotToDiffable(conn.request).run { request in
          Strategy<Response, String>.response.snapshotToDiffable(conn.response).run { response in
            callback(request + "\n\n" + response)
          }
        }
      }
    }
    conn.pathExtension = "Conn.txt"
    return conn
  }
}

extension Strategy where A == URLRequest, B == String {
  // TODO: move to snapshot-testing plugin library
  public static var request: Strategy<URLRequest, String> {
    var request = SimpleStrategy.lines.pullback { (request: URLRequest) in
      let headers = (request.allHTTPHeaderFields ?? [:])
        .map { key, value in "\(key): \(value)" }
        .sorted()

      // NB: `absoluteString` is necessary because of https://github.com/apple/swift-corelibs-foundation/pull/1312
      let lines = ["\(request.httpMethod ?? "GET") \((request.url?.absoluteString).map(String.init(describing:)) ?? "?")"]
        + headers
      return lines.joined(separator: "\n")
        + (request.httpBody.map { "\n\n\(String(decoding: $0, as: UTF8.self))" } ?? "")
    }
    request.pathExtension = "URLRequest.txt"
    return request
  }
}

extension Strategy where A == Response, B == String {
  public static var response: Strategy<Response, String> {
    var response = SimpleStrategy.lines.pullback { (response: Response) in
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
    response.pathExtension = "Response.txt"
    return response
  }
}

extension Conn: DefaultDiffable where Step == ResponseEnded, A == Data {
  public typealias B = String

  public static let defaultStrategy: Strategy<Conn<ResponseEnded, Data>, String> = .conn
}

extension URLRequest: DefaultDiffable {
  public static let defaultStrategy: Strategy<URLRequest, String> = .request
}

extension Response: DefaultDiffable {
  public static let defaultStrategy: Strategy<Response, String> = .response
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
