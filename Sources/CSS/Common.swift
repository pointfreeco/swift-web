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

public let noneValue: Value = "none"
public protocol None {
  static var none: Self { get }
}

public let normalValue: Value = "normal"
public protocol Normal {
  static var normal: Self { get }
}

public let centerValue: Value = "center"
public protocol Center {
  static var center: Self { get }
}

public let hiddenValue: Value = "hidden"
public protocol Hidden {
  static var hidden: Self { get }
}

public let visibleValue: Value = "visible"
public protocol Visible {
  static var visible: Self { get }
}

public let baselineValue: Value = "baseline"
public protocol Baseline {
  static var baseline: Self { get }
}

public let autoValue: Value = "auto"
public protocol Auto {
  static var auto: Self { get }
}

public let allValue: Value = "all"
public protocol All {
  static var all: Self { get }
}

public let initialValue: Value = "initial"
public protocol Initial {
  static var initial: Self { get }
}

public let unsetValue: Value = "unset"
public protocol Unset {
  static var unset: Self { get }
}

extension Value: Inherit, None {
  public static var inherit: Value { return inheritValue }
  public static var none: Value { return noneValue }
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
