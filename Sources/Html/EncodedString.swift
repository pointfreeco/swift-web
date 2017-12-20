import Foundation
import Prelude

public struct EncodedString {
  public let string: String
  internal init(_ string: String) {
    self.string = string
  }

  internal init(_ string: StaticString) {
    self.string = String(describing: string)
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

public func unsafeUnencodedString(_ string: String) -> EncodedString {
  return EncodedString(string)
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
