import Prelude

// MARK: - border-style

public struct BorderStyle: Val, Other, Inherit, Auto, None {
  let stroke: Value

  public func value() -> Value {
    return self.stroke
  }

  public static func other(_ other: Value) -> BorderStyle {
    return .init(stroke: other)
  }

  public static let auto = BorderStyle(stroke: .auto)
  public static let inherit = BorderStyle(stroke: .inherit)
  public static let none = BorderStyle(stroke: .none)

  public static let dashed: BorderStyle = "dashed"
  public static let dotted: BorderStyle = "dotted"
  public static let double: BorderStyle = "double"
  public static let groove: BorderStyle = "groove"
  public static let hidden: BorderStyle = "hidden"
  public static let inset: BorderStyle = "inset"
  public static let outset: BorderStyle = "outset"
  public static let ridge: BorderStyle = "ridge"
  public static let solid: BorderStyle = "solid"
}

extension BorderStyle: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = BorderStyle(stroke: .init(stringLiteral: value))
  }
}

public func borderStyle(top: BorderStyle? = nil,
                        right: BorderStyle? = nil,
                        bottom: BorderStyle? = nil,
                        left: BorderStyle? = nil) -> Stylesheet {

  return [ top.map { key("border-top-style", $0) },
           right.map { key("border-right-style", $0) },
           bottom.map { key("border-bottom-style", $0) },
           left.map { key("border-left-style", $0) } ]
    |> catOptionals
    |> concat
}

public func borderStyle(topBottom: BorderStyle? = nil, leftRight: BorderStyle? = nil) -> Stylesheet {
  return borderStyle(top: topBottom, bottom: topBottom)
    <> borderStyle(right: leftRight, left: leftRight)
}

public func borderStyle(all: BorderStyle) -> Stylesheet {
  return borderStyle(top: all, right: all, bottom: all, left: all)
}

// MARK: - border-*-radius

public func borderRadius(topLeft: Size? = nil,
                         topRight: Size? = nil,
                         bottomRight: Size? = nil,
                         bottomLeft: Size? = nil) -> Stylesheet {

  return [ topLeft.map { key("border-top-left-radius", $0) },
           topRight.map { key("border-top-right-radius", $0) },
           bottomRight.map { key("border-bottom-right-radius", $0) },
           bottomLeft.map { key("border-bottom-left-radius", $0) } ]
    |> catOptionals
    |> concat
}

public func borderRadius(top: Size? = nil, bottom: Size? = nil) -> Stylesheet {
  return borderRadius(topLeft: top, topRight: top)
    <> borderRadius(bottomRight: bottom, bottomLeft: bottom)
}

public func borderRadius(all: Size) -> Stylesheet {
  return borderRadius(topLeft: all, topRight: all, bottomRight: all, bottomLeft: all)
}

// MARK: - border-collapse

public let borderCollapse: (Visibility) -> Stylesheet = key("border-collapse")

// Mark: border-spacing

public let borderSpacing: (Size) -> Stylesheet = key("border-spacing")

// MARK: - border-color-*

public func borderColor(top: Color? = nil,
                        right: Color? = nil,
                        bottom: Color? = nil,
                        left: Color? = nil) -> Stylesheet {

  return [ top.map { key("border-top-color", $0) },
           right.map { key("border-right-color", $0) },
           bottom.map { key("border-bottom-color", $0) },
           left.map { key("border-left-color", $0) } ]
    |> catOptionals
    |> concat
}

public func borderColor(topBottom: Color? = nil, leftRight: Color? = nil) -> Stylesheet {
  return borderColor(top: topBottom, bottom: topBottom)
    <> borderColor(right: leftRight, left: leftRight)
}

public func borderColor(all: Color) -> Stylesheet {
  return borderColor(top: all, right: all, bottom: all, left: all)
}

// MARK: - border-width-*

public func borderWidth(top: Size? = nil,
                        right: Size? = nil,
                        bottom: Size? = nil,
                        left: Size? = nil) -> Stylesheet {

  return [ top.map { key("border-top-width", $0) },
           right.map { key("border-right-width", $0) },
           bottom.map { key("border-bottom-width", $0) },
           left.map { key("border-left-width", $0) } ]
    |> catOptionals
    |> concat
}

public func borderWidth(topBottom: Size? = nil, leftRight: Size? = nil) -> Stylesheet {
  return borderWidth(top: topBottom, bottom: topBottom)
    <> borderWidth(right: leftRight, left: leftRight)
}

public func borderWidth(all: Size) -> Stylesheet {
  return borderWidth(top: all, right: all, bottom: all, left: all)
}
