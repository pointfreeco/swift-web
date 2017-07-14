public protocol Other {
  static func other(_ other: Value) -> Self
}

func eq<A: Equatable>(lhsTuples xs: [(A, A)], rhsTuples ys: [(A, A)]) -> Bool {
  return xs.count == ys.count
    && zip(xs, ys).reduce(true) { accum, tuple in accum && tuple.0 == tuple.1 }
}

public let inheritValue: Value = "inherit"
public protocol Inherit {
  static var inherit: Self { get }
}
extension Value: Inherit {
  public static var inherit: Value { return inheritValue }
}

public let noneValue: Value = "none"
public protocol None {
  static var none: Self { get }
}
extension Value: None {
  public static var none: Value { return noneValue }
}

public let normalValue: Value = "normal"
public protocol Normal {
  static var normal: Self { get }
}
extension Value: Normal {
  public static var normal: Value { return normalValue }
}

public let centerValue: Value = "center"
public protocol Center {
  static var center: Self { get }
}
extension Value: Center {
  public static var center: Value { return centerValue }
}

public let hiddenValue: Value = "hidden"
public protocol Hidden {
  static var hidden: Self { get }
}
extension Value: Hidden {
  public static var hidden: Value { return hiddenValue }
}

public let visibleValue: Value = "visible"
public protocol Visible {
  static var visible: Self { get }
}
extension Value: Visible {
  public static var visible: Value { return visibleValue }
}

public let baselineValue: Value = "baseline"
public protocol Baseline {
  static var baseline: Self { get }
}
extension Value: Baseline {
  public static var baseline: Value { return baselineValue }
}

public let autoValue: Value = "auto"
public protocol Auto {
  static var auto: Self { get }
}
extension Value: Auto {
  public static var auto: Value { return autoValue }
}

public let allValue: Value = "all"
public protocol All {
  static var all: Self { get }
}
extension Value: All {
  public static var all: Value { return allValue }
}

public let initialValue: Value = "initial"
public protocol Initial {
  static var initial: Self { get }
}
extension Value: Initial {
  public static var initial: Value { return initialValue }
}

public let unsetValue: Value = "unset"
public protocol Unset {
  static var unset: Self { get }
}
extension Value: Unset {
  public static var unset: Value { return unsetValue }
}

public let browsers = Prefixed.prefixed(
  [
    ("-webkit-", ""),
    ("-moz-", ""),
    ("-ms-", ""),
    ("-o-", ""),
    ("", "")
  ]
)
