import Prelude

public struct BoxType: Val, Inherit {
  let boxType: Value

  public func value() -> Value {
    return self.boxType
  }

  public static let inherit = BoxType(boxType: .inherit)

  public static let paddingBox: BoxType = "padding-box"
  public static let borderBox: BoxType = "border-box"
  public static let contentBox: BoxType = "content-box"
}

extension BoxType: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(boxType: .init(stringLiteral: value))
  }
}

extension Stylesheet {
  public static func boxSizing(_ type: BoxType) -> Stylesheet {
    return prefixed(browsers <> "box-sizing", type)
  }
}
