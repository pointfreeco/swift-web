public struct Visibility: Val {
  let visibility: Value

  public func value() -> Value {
    return self.visibility
  }
}

extension Visibility: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = Visibility(visibility: .init(stringLiteral: value))
  }
}

public func visibility(_ v: Visibility) -> Stylesheet {
  return key("visibility", v)
}

public let collapse: Visibility = "collapse"
public let separate: Visibility = "separate"

public struct FloatStyle: Val, None, Inherit {
  let style: Value

  public func value() -> Value {
    return self.style
  }

  public static let none = FloatStyle(style: .none)
  public static let inherit = FloatStyle(style: .inherit)
}

extension FloatStyle: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(style: .init(stringLiteral: value))
  }
}

public let floatLeft: FloatStyle = "left"
public let floatRight: FloatStyle = "right"

public let float: (FloatStyle) -> Stylesheet = key("float")

public struct Clear: Val, Other, None, Inherit {
  let clear: Value

  public func value() -> Value {
    return self.clear
  }

  public static func other(_ other: Value) -> Clear {
    return .init(clear: other)
  }

  public static let none = Clear(clear: .none)
  public static let inherit = Clear(clear: .inherit)
}

extension Clear: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(clear: .init(stringLiteral: value))
  }
}

public let clearLeft: Clear = "left"
public let clearRight: Clear = "right"
public let clearBoth: Clear = "both"

public let clear: (Clear) -> Stylesheet = key("clear")

public struct Position: Val, Other, Inherit {
  let position: Value

  public func value() -> Value {
    return self.position
  }

  public static func other(_ other: Value) -> Position {
    return .init(position: other)
  }

  public static let inherit = Position(position: .inherit)
}

extension Position: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(position: .init(stringLiteral: value))
  }
}

public let `static`: Position = "static"
public let absolute: Position = "absolute"
public let fixed: Position = "fixed"
public let relative: Position = "relative"

public let position: (Position) -> Stylesheet = key("position")

public struct Display: Val, Other, None, Inherit {
  let display: Value

  public func value() -> Value {
    return self.display
  }

  public static func other(_ other: Value) -> Display {
    return .init(display: other)
  }

  public static let none = Display(display: .none)
  public static let inherit = Display(display: .inherit)
}

extension Display: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(display: .init(stringLiteral: value))
  }
}

public let block: Display = "block"
public let inlineBlock: Display = "inline-block"
public let displayTable: Display = "table"

public let display: (Display) -> Stylesheet = key("display")

public protocol VerticalAlign: Val {
  func verticalAlign() -> Stylesheet
}

public struct VerticalAlignValue: Val, Baseline, Center {
  let verticalAlign: Value

  init(_ verticalAlign: Value) {
    self.verticalAlign = verticalAlign
  }

  public func value() -> Value {
    return self.verticalAlign
  }

  public static let baseline = VerticalAlignValue(.baseline)
  public static let center = VerticalAlignValue(.center)
}

extension VerticalAlignValue: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(.init(stringLiteral: value))
  }
}

public let middle: VerticalAlignValue = "middle"
public let top: VerticalAlignValue = "top"
public let bottom: VerticalAlignValue = "bottom"
public let textTop: VerticalAlignValue = "text-top"
public let textBottom: VerticalAlignValue = "text-bottom"

public let verticalAlign: (VerticalAlignValue) -> Stylesheet = key("vertical-align")
