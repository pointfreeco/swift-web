public protocol Other {
  static func other(_ other: Value) -> Self
}

func eq<A: Equatable>(lhsTuples xs: [(A, A)], rhsTuples ys: [(A, A)]) -> Bool {
  return xs.count == ys.count
    && zip(xs, ys).reduce(true) { accum, tuple in accum && tuple.0 == tuple.1 }
}

public protocol Inherit {
  static var inherit: Self { get }
}
extension Value: Inherit {
  public static let inherit: Value = "inherit"
}

public protocol None {
  static var none: Self { get }
}
extension Value: None {
  public static let none: Value = "none"
}

public protocol Normal {
  static var normal: Self { get }
}
extension Value: Normal {
  public static let normal: Value = "normal"
}

public protocol Center {
  static var center: Self { get }
}
extension Value: Center {
  public static let center: Value = "center"
}

public protocol Hidden {
  static var hidden: Self { get }
}
extension Value: Hidden {
  public static let hidden: Value = "hidden"
}

public protocol Visible {
  static var visible: Self { get }
}
extension Value: Visible {
  public static let visible: Value = "visible"
}

public protocol Baseline {
  static var baseline: Self { get }
}
extension Value: Baseline {
  public static let baseline: Value = "baseline"
}

public protocol Auto {
  static var auto: Self { get }
}
extension Value: Auto {
  public static let auto: Value = "auto"
}

public protocol All {
  static var all: Self { get }
}
extension Value: All {
  public static let all: Value = "all"
}

public protocol Initial {
  static var initial: Self { get }
}
extension Value: Initial {
  public static let initial: Value = "initial"
}

public protocol Unset {
  static var unset: Self { get }
}
extension Value: Unset {
  public static let unset: Value = "unset"
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
