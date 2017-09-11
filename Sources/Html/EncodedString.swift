import Foundation
import Prelude

public struct EncodedString {
  public let string: String

  internal init(vouchedSafetyFor vouched: VouchedSafety) {
    self.string = vouched.string
  }

  internal init(_ string: StaticString) {
    self.string = String(describing: string)
  }
}

public struct VouchedSafety {
  let string: String

  init(vouched string: String) {
    self.string = string
  }
}

public func + (lhs: EncodedString, rhs: EncodedString) -> EncodedString {
  return .init(vouchedSafetyFor: .init(vouched: lhs.string + rhs.string))
}

extension EncodedString: Monoid {
  public static var empty: EncodedString = .init("")

  public static func <>(lhs: EncodedString, rhs: EncodedString) -> EncodedString {
    return lhs + rhs
  }
}

public func quote(_ string: EncodedString) -> EncodedString {
  return .init(vouchedSafetyFor: .init(vouched: "\"" + string.string + "\""))
}

public func encode(_ unencoded: String) -> EncodedString {
  return .init(
    vouchedSafetyFor: .init(
      vouched: unencoded
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&#39;")
    )
  )
}
