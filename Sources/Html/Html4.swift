public enum Html4Size: Value, CustomStringConvertible {
  case px(Int)
  case pct(Int)

  public var description: String {
    switch self {
    case let .px(size):
      return "\(size)"
    case let .pct(size):
      return "\(size)%"
    }
  }
}

public enum Alignment: String, Value {
  case left
  case right
  case center
  case justify
}
public func align<T>(_ value: Alignment) -> Attribute<T> {
  return .init("align", value)
}

public func border<T>(_ value: Int) -> Attribute<T> {
  return .init("border", value)
}

public func cellpadding(_ value: Int) -> Attribute<Element.Table> {
  return .init("cellpadding", value)
}

public func cellspacing(_ value: Int) -> Attribute<Element.Table> {
  return .init("cellspacing", value)
}

public func height<T>(_ value: Html4Size) -> Attribute<T> {
  return .init("height", value)
}

public enum VerticalAlignment: String, Value {
  case top
  case middle
  case bottom
  case baseline
}
public func valign<T>(_ value: VerticalAlignment) -> Attribute<T> {
  return .init("valign", value)
}

public func width<T>(_ value: Html4Size) -> Attribute<T> {
  return .init("width", value)
}
