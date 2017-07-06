import Prelude

public struct EdgeInsets: Val {
  let top: Size
  let right: Size
  let bottom: Size
  let left: Size

  public func value() -> Value {
    let space = Value(.plain(" "))
    return self.top.value()
      <> space
      <> right.value()
      <> space
      <> bottom.value()
      <> space
      <> left.value()
  }
}

public func padding(top: Size? = nil,
                    right: Size? = nil,
                    bottom: Size? = nil,
                    left: Size? = nil) -> Stylesheet {

  return [ top.map { key("padding-top", $0) },
           right.map { key("padding-right", $0) },
           bottom.map { key("padding-bottom", $0) },
           left.map { key("padding-left", $0) } ]
    |> catOptionals
    |> concat
}

public func padding(topBottom: Size? = nil, leftRight: Size? = nil) -> Stylesheet {

  return padding(top: topBottom, bottom: topBottom)
    <> padding(right: leftRight, left: leftRight)
}

public func padding(all: Size) -> Stylesheet {
  return padding(top: all, right: all, bottom: all, left: all)
}

public func margin(top: Size? = nil, right: Size? = nil, bottom: Size? = nil, left: Size? = nil) -> Stylesheet {

  return [ top.map { key("margin-top", $0) },
           right.map { key("margin-right", $0) },
           bottom.map { key("margin-bottom", $0) },
           left.map { key("margin-left", $0) } ]
    |> catOptionals
    |> concat
}

public func margin(topBottom: Size? = nil, leftRight: Size? = nil) -> Stylesheet {

  return margin(top: topBottom, bottom: topBottom)
    <> margin(right: leftRight, left: leftRight)
}

public func margin(all: Size) -> Stylesheet {
  return margin(top: all, right: all, bottom: all, left: all)
}

public let width: (Size) -> Stylesheet = key("width")
public func maxWidth(_ s: Size) -> Stylesheet {
  return s |> key("max-width")
}
public let minHeight: (Size) -> Stylesheet = key("min-height")
