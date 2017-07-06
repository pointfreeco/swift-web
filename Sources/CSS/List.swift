public struct ListStyleType: Val, Inherit, None {
  let type: Value

  public func value() -> Value {
    return self.type
  }

  public static var inherit: ListStyleType {
    return .init(type: inheritValue)
  }

  public static var none: ListStyleType {
    return .init(type: noneValue)
  }
}

public let listStyleType: (ListStyleType) -> Stylesheet = key("list-style-type")
