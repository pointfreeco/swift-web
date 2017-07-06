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

enum App {
  case `self`(CssSelector)
  case root(CssSelector)
  case pop(Int)
  case child(CssSelector)
  case sub(CssSelector)
}

struct Keyframes {
  let key: String
  let frames: [(Double, [Rule])]
}

enum Rule {
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

struct StyleM<A> {
  let writer: Writer<[Rule], A>
}

func >>- <A, B> (x: StyleM<A>, f: (A) -> StyleM<B>) -> StyleM<B> {
  return StyleM.init(writer: x.writer >>- { a in
    f(a).writer
  })
}

public struct Stylesheet {
  let unStyleM: StyleM<Unit>

  init(_ styleM: StyleM<Unit>) {
    self.unStyleM = styleM
  }
}

func >>- (x: Stylesheet, f: (Unit) -> Stylesheet) -> Stylesheet {
  return Stylesheet.init(x.unStyleM >>- { a in
    f(a).unStyleM
  })
}

func runS(_ css: Stylesheet) -> [Rule] {
  return css.unStyleM.writer.exec()
}

func rule(_ r: Rule) -> Stylesheet {
  return Stylesheet(StyleM(writer: .tell([r])))
}

extension Stylesheet: Monoid {

  public static var empty: Stylesheet = Stylesheet.init(StyleM<Unit>.init(writer: .pure(unit)))

  public static func <>(lhs: Stylesheet, rhs: Stylesheet) -> Stylesheet {
    return Stylesheet(
      StyleM<Unit>(
        writer: Writer<[Rule], Unit>(
          m: lhs.unStyleM.writer.exec() <> rhs.unStyleM.writer.exec(),
          a: unit
        )
      )
    )
  }
}

func key<V: Val>(_ key: Key<V>, _ a: V) -> Stylesheet {
  return rule(.property(cast(key), a.value()))
}

func key<V: Val>(_ key: Key<V>) -> (V) -> Stylesheet {
  return { rule(.property(cast(key), $0.value())) }
}

func prefixed<A: Val>(_ prefixed: Prefixed, _ a: A) -> Stylesheet {
  return key(Key(prefixed), a.value())
}

public func % (sel: CssSelector, rs: Stylesheet) -> Stylesheet {
  return rule(.nested(.sub(sel), rs.unStyleM.writer.exec()))
}

public func & (sel: CssSelector, rs: Stylesheet) -> Stylesheet {
  return rule(.nested(.`self`(sel), rs.unStyleM.writer.exec()))
}

public func query(_ mediaType: MediaType, _ features: [Feature], rs: () -> Stylesheet) -> Stylesheet {

  return rule(Rule.query(MediaQuery.init(notOrOnly: nil, mediaType: mediaType, features: features), rs().unStyleM.writer.exec()))

}

public func queryNot(_ mediaType: MediaType, _ features: [Feature], rs: () -> Stylesheet) -> Stylesheet {

  return rule(
    .query(
      .init(notOrOnly: .some(.not), mediaType: mediaType, features: features),
      rs().unStyleM.writer.exec()
    )
  )
}

public func queryOnly(_ mediaType: MediaType, _ features: [Feature], rs: () -> Stylesheet) -> Stylesheet {

  return rule(
    .query(
      .init(notOrOnly: .some(.only), mediaType: mediaType, features: features),
      rs().unStyleM.writer.exec()
    )
  )
}
