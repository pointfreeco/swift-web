public struct ListStyleType: Val, Inherit, None {
  let type: Value

  public func value() -> Value {
    return self.type
  }

  public static let inherit = ListStyleType(type: .inherit)
  public static let none = ListStyleType(type: .none)
}

public let listStyleType: (ListStyleType) -> Stylesheet = key("list-style-type")
