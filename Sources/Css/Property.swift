import Prelude

public enum Prefixed {
  case plain(String)
  case prefixed([(String, String)])
}

extension Prefixed: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .plain(value)
  }
}

extension Prefixed: Equatable {
  public static func ==(lhs: Prefixed, rhs: Prefixed) -> Bool {
    switch (lhs, rhs) {
    case let (.plain(x), .plain(y)):
      return x == y
    case (.plain, .prefixed), (.prefixed, .plain):
      return false
    case let (.prefixed(xs), .prefixed(ys)):
      return eq(lhsTuples: xs, rhsTuples: ys)
    }
  }
}

//extension Prefixed: ExpressibleByString {
//  public static func from(string: String) -> Prefixed {
//    return .plain(String.from(string: string))
//  }
//}

extension Prefixed: Monoid {
  public static let empty = Prefixed.plain("")

  public static func <>(lhs: Prefixed, rhs: Prefixed) -> Prefixed {
    switch (lhs, rhs) {
    case let (.plain(x), .plain(y)):
      return .plain(x + y)
    case let (.plain(x), .prefixed(ys)):
      return .prefixed(ys.map(second(x<>)))
    case let (.prefixed(xs), .plain(y)):
      return .prefixed(xs.map(second(<>y)))
    case let (.prefixed(xs), .prefixed(ys)):

      let kxs = xs.map(first)
      let kys = ys.map(first)

      let a = xs
        |> partition(first >>> elem(of: kys))
        |> first
        |> sorted(by: lexographicSort)
      let b = ys
        |> partition(first >>> elem(of: kxs))
        |> first
        |> sorted(by: lexographicSort)

      return .prefixed(
        zipWith({ lhs, rhs in (lhs.0, lhs.1 + rhs.1) })(a)(b)
      )
    }
  }
}

public func plain(_ prefixed: Prefixed) -> String {
  switch prefixed {
  case let .plain(str):
    return str
  case let .prefixed(xs):
    return xs |> lookup("") |> coalesce(with: "")
  }
}

public struct Key<A> {
  let unKeys: Prefixed
  init(_ keys: Prefixed) {
    self.unKeys = keys
  }
}

extension Key: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(.plain(value))
  }
}

func cast<A>(_ x: Key<A>) -> Key<Unit> {
  return .init(x.unKeys)
}

public struct Value {
  let unValue: Prefixed
  init(_ unValue: Prefixed) {
    self.unValue = unValue
  }
}

extension Value: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(.plain(value))
  }
}

extension Value: Equatable {
  public static func ==(lhs: Value, rhs: Value) -> Bool {
    return lhs.unValue == rhs.unValue
  }
}

extension Value: Monoid {
  public static func <>(lhs: Value, rhs: Value) -> Value {
    return .init(lhs.unValue <> rhs.unValue)
  }

  public static let empty = Value(.empty)
}

public protocol Val {
  func value() -> Value
}

extension String: Val {
  public func value() -> Value {
    return .init(.plain(self))
  }
}

struct Literal {
  let string: String
  init(_ string: String) {
    self.string = string
  }
}

extension Literal: Val {
  func value() -> Value {
    return .init(.plain(quote(self.string)))
  }
}

extension Int: Val {
  public func value() -> Value {
    return .init(.plain(String(self)))
  }
}

extension Double: Val {
  public func value() -> Value {
    return .init(.plain(String(self)))
  }
}

extension Value: Val {
  public func value() -> Value {
    return self
  }
}

private func quote(_ string: String) -> String {
  let q = "\""
  let str = String(string.split(separator: "\"").joined(separator: "\\\""))
  return q + str + q
}

private func lexographicSort<A: Comparable, B: Comparable>(_ lhs: (A, B), _ rhs: (A, B)) -> Bool {
  return lhs.0 < rhs.0 || (lhs.0 == rhs.0 && lhs.1 < rhs.1)
}
