import Prelude

public struct MediaType: Val, Other {
  let mediaType: Value

  public init(_ value: Value) {
    self.mediaType = value
  }

  public func value() -> Value {
    return self.mediaType
  }

  public static func other(_ value: Value) -> MediaType {
    return .init(value)
  }
}

extension MediaType: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(.init(stringLiteral: value))
  }
}

public let screen: MediaType = "screen"
public let print: MediaType = "print"
public let all: MediaType = "all"

public enum NotOrOnly {
  case not
  case only
}

public struct MediaQuery {
  let notOrOnly: NotOrOnly?
  let mediaType: MediaType
  let features: [Feature]
}

public struct Feature {
  let key: String
  let value: Value?
}

public enum App {
  case `self`(CssSelector)
  case root(CssSelector)
  case pop(Int)
  case child(CssSelector)
  case sub(CssSelector)
}

public struct Keyframes {
  let key: String
  let frames: [(Double, [Rule])]
}

public enum Rule {
  case property(Key<Unit>, Value)
  case nested(App, [Rule])
  case query(MediaQuery, [Rule])
  case face([Rule])
  case keyframe(Keyframes)
  case `import`(String)

  var property: (Key<Unit>, Value)? {
    switch self {
    case let .property(k, v): return (k, v)
    default:                  return nil
    }
  }

  var nested: (App, [Rule])? {
    switch self {
    case let .nested(a, rs): return (a, rs)
    default:                   return nil
    }
  }

  var query: (MediaQuery, [Rule])? {
    switch self {
    case let .query(m, rs): return (m, rs)
    default:                return nil
    }
  }

  var face: [Rule]? {
    switch self {
    case let .face(rs): return rs
    default:            return nil
    }
  }

  var keyframes: Keyframes? {
    switch self {
    case let .keyframe(k): return k
    default:               return nil
    }
  }

  var `import`: String? {
    switch self {
    case let .`import`(k): return k
    default:               return nil
    }
  }
}

public struct Stylesheet {
  public let rules: [Rule]

  init(_ rules: [Rule]) {
    self.rules = rules
  }
}

func runS(_ css: Stylesheet) -> [Rule] {
  return css.rules
}

func rule(_ r: Rule) -> Stylesheet {
  return Stylesheet([r])
}

extension Stylesheet: Monoid {
  public static var empty: Stylesheet = Stylesheet([])

  public static func <>(lhs: Stylesheet, rhs: Stylesheet) -> Stylesheet {
    return .init(lhs.rules <> rhs.rules)
  }
}

public func key<V: Val>(_ key: Key<V>, _ a: V) -> Stylesheet {
  return rule(.property(cast(key), a.value()))
}

public func key<V: Val>(_ key: Key<V>) -> (V) -> Stylesheet {
  return { rule(.property(cast(key), $0.value())) }
}

public func prefixed<A: Val>(_ prefixed: Prefixed, _ a: A) -> Stylesheet {
  return key(Key(prefixed), a.value())
}

public func % (sel: CssSelector, rs: Stylesheet) -> Stylesheet {
  return rule(.nested(.sub(sel), rs.rules))
}

public func & (sel: CssSelector, rs: Stylesheet) -> Stylesheet {
  return rule(.nested(.`self`(sel), rs.rules))
}

public func query(_ mediaType: MediaType, _ features: [Feature], rs: Stylesheet) -> Stylesheet {

  return rule(Rule.query(MediaQuery.init(notOrOnly: nil, mediaType: mediaType, features: features), rs.rules))

}

public func queryNot(_ mediaType: MediaType, _ features: [Feature], rs: () -> Stylesheet) -> Stylesheet {

  return rule(
    .query(
      .init(notOrOnly: .some(.not), mediaType: mediaType, features: features),
      rs().rules
    )
  )
}

public func queryOnly(_ mediaType: MediaType, _ features: [Feature], rs: () -> Stylesheet) -> Stylesheet {

  return rule(
    .query(
      .init(notOrOnly: .some(.only), mediaType: mediaType, features: features),
      rs().rules
    )
  )
}
