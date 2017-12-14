import Foundation
import Prelude
import UrlFormEncoding

struct RequestData: Monoid {
  var method: Method? = nil
  var path: [String] = []
  var query: String? = nil
  var body: Data? = nil

  static var empty = RequestData()

  static func <>(lhs: RequestData, rhs: RequestData) -> RequestData {
    let query = (curry { $0 <> "&" <> $1 } <¢> lhs.query <*> rhs.query)
      ?? lhs.query
      ?? rhs.query

    return .init(
      method: lhs.method ?? rhs.method,
      path: lhs.path + rhs.path,
      query: query,
      // todo: is coalescing enough or should we be appending?
      body: lhs.body ?? rhs.body
    )
  }

  // TODO: optimize
  var params: [String: String] {
    return self.query
      .map {
        parse(query: $0)
          .reduce(into: [:]) { params, pair in
            params[pair.0] = pair.1 ?? ""
        }
      }
      ?? [:]
  }
}
