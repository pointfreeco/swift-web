
public func width(_ size: Size) -> Feature {
  return .init(key: "width", value: size.value())
}

public func maxWidth(_ size: Size) -> Feature {
  return .init(key: "max-width", value: size.value())
}

public func minWidth(_ size: Size) -> Feature {
  return .init(key: "min-width", value: size.value())
}
