import Foundation
import Prelude
import Optics

// todo: move to prelude
public func >-> <A, B, C>(lhs: @escaping (A) -> B?, rhs: @escaping (B) -> C?) -> (A) -> C? {
  return { a in lhs(a).flatMap(rhs) }
}

// todo: move to prelude?
struct Iso<A, B> {
  let image: (A) -> B?
  let preimage: (B) -> A?

  var inverted: Iso<B, A> {
    return .init(image: self.preimage, preimage: self.image)
  }

  static var commute: Iso<(A, B), (B, A)> {
    return .init(
      image: { ($1, $0) },
      preimage: { ($1, $0) }
    )
  }

  static func >>> <C> (lhs: Iso<A, B>, rhs: Iso<B, C>) -> Iso<A, C> {
    return .init(
      image: lhs.image >-> rhs.image,
      preimage: rhs.preimage >-> lhs.preimage
    )
  }

  static var id: Iso<A, A> {
    return .init(image: { $0 }, preimage: { $0 })
  }
}

// todo: since we are using the appliciatve `f a -> f b -> f (a, b)` we will often run into left-paranthesized
// nested tuples (((A, B), C), D), so we will need many overloads of `flatten` to correct this :/
func flatten<A, B, C>() -> Iso<((A, B), C), (A, B, C)> {
  return Iso<((A, B), C), (A, B, C)>(
    image: { ($0.0.0, $0.0.1, $0.1) },
    preimage: { (($0, $1), $2) }
  )
}

extension Iso where B == (A, Prelude.Unit) {
  static var unit: Iso {
    return .init(
      image: { ($0, Prelude.unit) },
      preimage: { $0.0 }
    )
  }
}

fileprivate struct _Route: Monoid {
  static var empty = _Route()

  static func <>(lhs: _Route, rhs: _Route) -> _Route {
    return .init(
      method: lhs.method ?? rhs.method,
      path: lhs.path + rhs.path,
      query: lhs.query.merging(rhs.query, uniquingKeysWith: { a, _ in a }),
      body: lhs.body ?? rhs.body
    )
  }

  var method: Method? = .get
  var path: [String] = []
  var query: [String: String] = [:]
  var body: Data? = nil
}

// TODO: should this be generic over any monoid `M` instead of using `_Route` directly?
struct Router<A> {
  fileprivate let parse: (_Route) -> (rest: _Route, match: A)?
  fileprivate let _print: (A) -> _Route?

  // todo:
  // fileprivate let templatePrint: (A) -> _Route?

  public func match(_ request: URLRequest) -> A? {
    return self.parse(route(from: request))?.match
  }

  public func print(_ a: A) -> URLRequest? {
    guard let route = self._print(a) else { return nil }

    var components = URLComponents()
    components.path = route.path.joined(separator: "/")
    components.queryItems = route.query.map(URLQueryItem.init(name:value:))

    var request = components.url.map { URLRequest(url: $0) }
    request?.httpMethod = route.method?.rawValue
    request?.httpBody = route.body
    return request
  }
}

// Functor

extension Router {
  func map<B>(_ f: Iso<A, B>) -> Router<B> {
    return f <¢> self
  }

  static func <¢> <B> (lhs: Iso<A, B>, rhs: Router) -> Router<B> {
    return Router<B>(
      parse: { route in
        guard let (rest, match) = rhs.parse(route) else { return nil }
        return lhs.image(match).map { (rest, $0) }
      },
      _print: lhs.preimage >-> rhs._print
    )
  }

  // TODO: how?
//  static func ¢> (lhs: Router<()>, rhs: A) -> Router {
//    fatalError()
//  }
}

// Applicative

extension Router {
  // todo: this form of applicative is right associative, but `<*>` is defined as infixl. maybe we should make
  // a right associative version and call it `<%>` or something?
  static func <*> <B> (lhs: Router, rhs: Router<B>) -> Router<(A, B)> {
    return Router<(A, B)>(
      parse: { str in
        guard let (more, a) = lhs.parse(str) else { return nil }
        guard let (rest, b) = rhs.parse(more) else { return nil }
        return (rest, (a, b))
    },
      _print: { ab in
        let lhsPrint = lhs._print(ab.0)
        let rhsPrint = rhs._print(ab.1)
        return (curry(<>) <¢> lhsPrint <*> rhsPrint) ?? lhsPrint ?? rhsPrint
    })
  }
}

extension Router where A == Prelude.Unit {
  static func <* <B>(x: Router<B>, y: Router) -> Router<B> {
    return Iso.unit.inverted <¢> (x <*> y) // <- this applicative is right associative
  }
}

extension Router {
  static func *> (x: Router<Prelude.Unit>, y: Router) -> Router {
    return (Iso.commute >>> Iso.unit.inverted) <¢> (x <*> y)
  }
}

func pure<A: Equatable>(_ a: A) -> Router<A> {
  return Router<A>(
    parse: { ($0, a) },
    _print: { a == $0 ? .empty : nil }
  )
}

// Alternative

extension Router {
  static func <|> (lhs: Router, rhs: Router) -> Router {
    return Router<A>(
      parse: { lhs.parse($0) ?? rhs.parse($0) },
      _print: { lhs._print($0) ?? rhs._print($0) }
    )
  }
}

extension Router {
  public static var empty: Router {
    return Router(
      parse: const(nil),
      _print: const(nil)
    )
  }
}

// Combinators

func lit(_ str: String) -> Router<Prelude.Unit> {
  return Router<Prelude.Unit>(
    parse: { route in
      guard let (_, ps) = uncons(route.path) else { return nil }
      return (_Route(method: route.method, path: ps, query: route.query, body: route.body), unit)
    },
    _print: { a in
      return _Route.init(method: nil, path: [str], query: [:], body: nil)
  })
}

func pathComponent<A>(_ key: String, _ f: Iso<String, A>) -> Router<A> {
  return Router<A>(
    parse: { route in
      guard let (p, ps) = uncons(route.path), let v = f.image(p) else { return nil }
      return (_Route(method: route.method, path: ps, query: route.query, body: route.body), v)
    },
    _print: { a in
      return _Route.init(method: nil, path: [f.preimage(a) ?? ":\(key)"], query: [:], body: nil)
  })
}

func param(_ key: String) -> Router<String> {
  return Router<String>(
    parse: { route in
      guard let str = route.query[key] else { return nil }
      return (route, str)
    },
    _print: { (a) -> _Route? in
      return _Route(method: nil, path: [], query: [key: a], body: nil)
  })
}

let _end = Router<Prelude.Unit>(
  parse: { route in
    guard route.path.isEmpty else { return nil }
    return (_Route(method: route.method, path: [], query: [:], body: nil), unit)
  },
  _print: { _ in .empty }
)

func int(_ key: String) -> Router<Int> {
  return pathComponent(key, intStringIso)
}

func str(_ key: String) -> Router<String> {
  return pathComponent(key, .id)
}

func num(_ key: String) -> Router<Double> {
  return pathComponent(key, doubleStringIso)
}

let intStringIso = Iso<String, Int>(
  image: Int.init,
  preimage: String.init
)
let doubleStringIso = Iso<String, Double>(
  image: Double.init,
  preimage: String.init
)

fileprivate func route(from request: URLRequest) -> _Route {
  let method = request.httpMethod.flatMap(Method.init(string:)) ?? .get

  guard let components = request.url.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) })
    else { return _Route(method: method, path: [], query: [:], body: request.httpBody) }

  let path = components.path.components(separatedBy: "/")
    |> mapOptional { $0.isEmpty ? nil : $0 }

  var query: [String: String] = [:]
  components.queryItems?.forEach { query[$0.name] = $0.value ?? "" }

  return _Route.init(method: method, path: path, query: query, body: request.httpBody)
}
