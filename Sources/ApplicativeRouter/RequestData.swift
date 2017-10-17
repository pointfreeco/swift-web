import Foundation
import Prelude

struct RequestData: Monoid {
  var method: Method? = .get
  var path: [String] = []
  var query: [String: String] = [:]
  var body: Data? = nil

  static var empty = RequestData()

  static func <>(lhs: RequestData, rhs: RequestData) -> RequestData {
    return .init(
      method: lhs.method ?? rhs.method,
      path: lhs.path + rhs.path,
      query: lhs.query.merging(rhs.query, uniquingKeysWith: { $1 }),
      // todo: is coalescing enough or should we be appending?
      body: lhs.body ?? rhs.body
    )
  }
}
