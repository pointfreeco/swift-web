import Foundation
import HttpPipeline
import MediaType
import SnapshotTesting
import XCTest

extension Response: Snapshot {
  public typealias Format = String

  public static var snapshotPathExtension: String? {
    return "response.txt"
  }

  public var snapshotFormat: String {
    let top = """
Status \(self.status.rawValue) (\(self.status))
Headers: [
  \(self.headers.sorted(by: \.description).map { $0.description }.joined(separator: "\n  "))
]
Bytes: \(self.body?.count ?? 0)
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
