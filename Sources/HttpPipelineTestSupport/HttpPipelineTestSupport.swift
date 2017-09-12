import Foundation
import HttpPipeline
import MediaType
import SnapshotTesting
import XCTest

extension Response: Snapshot {
  public typealias Format = String

  public static var snapshotPathExtension: String? {
    return "Response.txt"
  }

  public var snapshotFormat: String {
    let top = """
Status \(self.status.rawValue) \(String(describing: self.status).uppercased())
\(self.headers.map { $0.description }.sorted().joined(separator: "\n"))
"""

    let contentMediaType: MediaType? = self.headers
      .flatMap {
        if case let .contentType(mediaType) = $0 {
          return mediaType
        }
        return nil
    }.first

    if contentMediaType?.application?.isOther == .some(true) || contentMediaType?.isText == .some(true) {
      // todo: use proper encoding when available
      return top + "\n\n\(self.body.flatMap { String(data: $0, encoding: .utf8) } ?? "")\n"
    }
    return top
  }
}

// todo: move to prelude
extension Sequence {
  fileprivate func sorted<C: Comparable>(by keyPath: KeyPath<Element, C>) -> [Element] {
    return self.sorted { lhs, rhs in
      lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
    }
  }
}

extension Conn: Snapshot {
  public var snapshotFormat: String {
    return """
Step:
-----
\(Step.self)

Request:
--------
\(self.request.snapshotFormat)

Response:
---------
\(self.response.snapshotFormat)
"""
  }

  public static var snapshotPathExtension: String? {
    return "Conn.txt"
  }
}

// Todo: move to snapshot lib
extension URLRequest: Snapshot {

  public var snapshotFormat: String {
    let headers = (self.allHTTPHeaderFields ?? [:])
      .map { key, value in
        "  \(key): \(value)"
      }
      .joined(separator: "\n  ")

    let body = self.httpBody.flatMap { String(data: $0, encoding: .utf8) }
      ?? "(Data, \(self.httpBody?.count ?? 0) bytes)"

    return """
URL: \(self.url.map(String.init(describing:)) ?? "None")
Method: \(self.httpMethod ?? "GET")
Headers: [
  \(headers)
]
Body: \(body)
"""
  }

  public static var snapshotPathExtension: String? {
    return "URLRequest.txt"
  }
}
