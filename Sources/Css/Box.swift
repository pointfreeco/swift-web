import Prelude

public struct BoxType: Val, Inherit {
  let boxType: Value

  public func value() -> Value {
    return self.boxType
  }

  public static let inherit = BoxType(boxType: .inherit)
}

extension BoxType: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(boxType: .init(stringLiteral: value))
  }
}

public let paddingBox: BoxType = "padding-box"
public let borderBox: BoxType = "border-box"
public let contentBox: BoxType = "content-box"

public func boxSizing(_ type: BoxType) -> Stylesheet {
  return prefixed(browsers <> "box-sizing", type)
}
