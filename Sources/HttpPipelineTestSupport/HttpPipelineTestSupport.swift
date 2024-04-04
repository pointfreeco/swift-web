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

extension Async {
    func runAsync() async -> Value {
        await withCheckedContinuation { continuation in
            run { value in
                continuation.resume(returning: value)
            }
        }
    }

    static func withAsyncRun(_ run: @escaping () async -> Value) -> Self {
        return Async { callback in
            Task {
                let value = await run()
                callback(value)
            }
        }
    }
}

extension Snapshotting {
    func swiftAsyncPullback<NewValue>(
        _ transform: @escaping (_ otherValue: NewValue) async -> Value
    ) -> Snapshotting<NewValue, Format> {
        Snapshotting<NewValue, Format>(
            pathExtension: self.pathExtension,
            diffing: self.diffing
        ) { newValue in
            return .withAsyncRun { [self] in
                let value = await transform(newValue)
                return await self.snapshot(value).runAsync()
            }
        }
    }
}

extension Snapshotting where Value == Conn<ResponseEnded, Data>, Format == String {
  public static let conn = SimplySnapshotting.lines.swiftAsyncPullback { (conn: Conn<ResponseEnded, Data>) in
    async let request = Snapshotting<URLRequest, String>.raw.snapshot(conn.request.toURLRequest()!).runAsync()
      async let response = Snapshotting<Response, String>.response.snapshot(conn.response).runAsync()
      return await request + response
  } |> \.pathExtension .~ "Conn.txt"
}

extension Snapshotting where Value == Response, Format == String {
  public static let response = SimplySnapshotting.lines.pullback { (response: Response) in
    let lines = ["\(response.status.description)"]
      + response.headers.map { $0.description }.sorted()
    let top = lines.joined(separator: "\n")

    let isApplicationOrText = response.headers
      .first(where: { $0.name.canonicalName == "content-type" })
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
