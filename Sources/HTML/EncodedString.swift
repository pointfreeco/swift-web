import Foundation
import Prelude

public struct EncodedString {
  internal let string: String
  internal init(_ string: String) {
    self.string = string
  }
}

public func + (lhs: EncodedString, rhs: EncodedString) -> EncodedString {
  return .init(lhs.string + rhs.string)
}

extension EncodedString: Monoid {
  public static var empty: EncodedString = .init("")

  public static func <>(lhs: EncodedString, rhs: EncodedString) -> EncodedString {
    return lhs + rhs
  }
}

public func quote(_ string: EncodedString) -> EncodedString {
  return .init("\"" + string.string + "\"")
}

public func encode(_ unencoded: String) -> EncodedString {
  return .init(
    unencoded
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")
      .replacingOccurrences(of: "\"", with: "&quot;")
      .replacingOccurrences(of: "'", with: "&#39;")
  )
}
