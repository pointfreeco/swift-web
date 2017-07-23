public struct Visibility: Val {
  let visibility: Value

  public func value() -> Value {
    return self.visibility
  }

  public static let collapse: Visibility = "collapse"
  public static let separate: Visibility = "separate"
}

extension Visibility: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = Visibility(visibility: .init(stringLiteral: value))
  }
}

extension Stylesheet {
  public static let visibility: (Visibility) -> Stylesheet = key("visibility")
}

public struct FloatStyle: Val, None, Inherit {
  let style: Value

  public func value() -> Value {
    return self.style
  }

  public static let none = FloatStyle(style: .none)
  public static let inherit = FloatStyle(style: .inherit)

  public static let left: FloatStyle = "left"
  public static let right: FloatStyle = "right"
}

extension Stylesheet {
  public static let float: (FloatStyle) -> Stylesheet = key("float")
}

extension FloatStyle: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(style: .init(stringLiteral: value))
  }
}

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

  public static let clearLeft: Clear = "left"
  public static let clearRight: Clear = "right"
  public static let clearBoth: Clear = "both"
}

extension Clear: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(clear: .init(stringLiteral: value))
  }
}

extension Stylesheet {
  public static let clear: (Clear) -> Stylesheet = key("clear")
}

public struct Position: Val, Other, Inherit {
  let position: Value

  public func value() -> Value {
    return self.position
  }

  public static func other(_ other: Value) -> Position {
    return .init(position: other)
  }

  public static let inherit = Position(position: .inherit)

  public static let `static`: Position = "static"
  public static let absolute: Position = "absolute"
  public static let fixed: Position = "fixed"
  public static let relative: Position = "relative"
}

extension Position: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(position: .init(stringLiteral: value))
  }
}

extension Stylesheet {
  public static let position: (Position) -> Stylesheet = key("position")
}

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

  public static let block: Display = "block"
  public static let inlineBlock: Display = "inline-block"
  public static let table: Display = "table"
}

extension Display: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(display: .init(stringLiteral: value))
  }
}

extension Stylesheet {
  public static let display: (Display) -> Stylesheet = key("display")
}

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

  public static let middle: VerticalAlignValue = "middle"
  public static let top: VerticalAlignValue = "top"
  public static let bottom: VerticalAlignValue = "bottom"
  public static let textTop: VerticalAlignValue = "text-top"
  public static let textBottom: VerticalAlignValue = "text-bottom"
}

extension VerticalAlignValue: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(.init(stringLiteral: value))
  }
}

extension Stylesheet {
  public static let verticalAlign: (VerticalAlignValue) -> Stylesheet = key("vertical-align")
}
