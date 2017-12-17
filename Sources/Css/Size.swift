import Prelude

indirect public enum Size: Val, Auto, Normal, Inherit, None, Other {
  case simple(String)
  case sum(Size, Size)
  case diff(Size, Size)
  case mult(Double, Size)
  case div(Size, Double)
  case otherSize(Value)

  public func value() -> Value {
    switch self {
    case let .simple(s):
      return .init(.plain(s))
    case let .otherSize(s):
      return s

    case .sum, .diff, .mult, .div:
      return .init(browsers <> .plain("calc" <> renderExpression(size: self)))
    }
  }

  public static func other(_ other: Value) -> Size {
    return .otherSize(other)
  }

  public static let auto = Size.otherSize(.auto)
  public static let inherit = Size.otherSize(.inherit)
  public static let none = Size.otherSize(.none)
  public static let normal = Size.otherSize(.normal)

  public static func pct(_ d: Double) -> Size {
    return .simple(trunc(d) + "%")
  }

  public static func px(_ d: Double) -> Size {
    return .simple(trunc(d) + "px")
  }

  public static func rem(_ d: Double) -> Size {
    return .simple(trunc(d) + "rem")
  }

  public static func em(_ d: Double) -> Size {
    return .simple(trunc(d) + "em")
  }

  public static func unitless(_ d: Double) -> Size {
    return .simple(trunc(d))
  }

  public static func pt(_ d: Double) -> Size {
    return .simple(trunc(d) + "pt")
  }
}

private func renderExpression(size: Size) -> String {
  switch size {
  case let .simple(size):
    return size
  case let .sum(lhs, rhs):
    return "(" + renderExpression(size: lhs) + " + " + renderExpression(size: rhs) + ")"
  case let .diff(lhs, rhs):
    return "(" + renderExpression(size: lhs) + " - " + renderExpression(size: rhs) + ")"
  case let .mult(factor, size):
    return "(" + String(factor) + " * " + renderExpression(size: size) + ")"
  case let .div(size, factor):
    return "(" + renderExpression(size: size) + " / " + String(factor) + ")"
  case let .otherSize(sizeValue):
    return plain(sizeValue.unValue)
  }
}

private func trunc(_ d: Double) -> String {
  let s = String(d)
  return s.hasSuffix(".0") ? String(s.dropLast(2)) : s
}

public func + (lhs: Size, rhs: Size) -> Size {
  return .sum(lhs, rhs)
}

public func - (lhs: Size, rhs: Size) -> Size {
  return .diff(lhs, rhs)
}

public func * (lhs: Double, rhs: Size) -> Size {
  return .mult(lhs, rhs)
}

public func / (lhs: Size, rhs: Double) -> Size {
  return .div(lhs, rhs)
}

extension Size: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .simple(value)
  }
}

extension Size: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self = .simple("\(value)")
  }
}

extension Size: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) {
    self = .simple("\(value)")
  }
}
