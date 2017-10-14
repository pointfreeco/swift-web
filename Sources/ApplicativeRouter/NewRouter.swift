import Foundation
import Prelude
import Optics

// todo: use a profunctor Iso?
//typealias Iso_<S, T, A, B> = ((S) -> A) -> ((B) -> T)

// todo: move to prelude: right associative applicative
infix operator <%>: infixr4
infix operator %>: infixr4
infix operator <%: infixr4

// todo: move to prelude
public func >-> <A, B, C>(lhs: @escaping (A) -> B?, rhs: @escaping (B) -> C?) -> (A) -> C? {
  return { a in lhs(a).flatMap(rhs) }
}

// todo: move to prelude?
struct PartialIso<A, B> {
  let image: (A) -> B?
  let preimage: (B) -> A?

  var inverted: PartialIso<B, A> {
    return .init(image: self.preimage, preimage: self.image)
  }

  static var commute: PartialIso<(A, B), (B, A)> {
    return .init(
      image: { ($1, $0) },
      preimage: { ($1, $0) }
    )
  }

  static func >>> <C> (lhs: PartialIso<A, B>, rhs: PartialIso<B, C>) -> PartialIso<A, C> {
    return .init(
      image: lhs.image >-> rhs.image,
      preimage: rhs.preimage >-> lhs.preimage
    )
  }

  static var id: PartialIso<A, A> {
    return .init(image: { $0 }, preimage: { $0 })
  }
}

// todo: since we are using the appliciatve `f a -> f b -> f (a, b)` we will often run into right-paranthesized
// nested tuples e.g. (A, (B, (C, D))), so we will need many overloads of `flatten` to correct this :/

func flatten<A, B, C>() -> PartialIso<(A, (B, C)), (A, B, C)> {
  return .init(
    image: { ($0.0, $0.1.0, $0.1.1) },
    preimage: { ($0, ($1, $2)) }
  )
}

func flatten<A, B, C, D>() -> PartialIso<(A, (B, (C, D))), (A, B, C, D)> {
  return .init(
    image: { ($0.0, $0.1.0, $0.1.1.0, $0.1.1.1) },
    preimage: { ($0, ($1, ($2, $3))) }
  )
}

func curry<A, B, C, D>(_ f: PartialIso<(A, B, C), D>) -> PartialIso<(A, (B, C)), D> {
  return flatten() >>> f
}

func curry<A, B, C, D, E>(_ f: PartialIso<(A, B, C ,D), E>) -> PartialIso<(A, (B, (C, D))), E> {
  return flatten() >>> f
}

func curry<A, B, C>(_ f: PartialIso<(A, B), C>) -> PartialIso<(A, B), C> {
  return f
}

func curry<A, B>(_ f: PartialIso<A, B>) -> PartialIso<A, B> {
  return f
}

extension PartialIso where B == (A, Prelude.Unit) {
  static var unit: PartialIso {
    return .init(
      image: { ($0, Prelude.unit) },
      preimage: { $0.0 }
    )
  }
}

fileprivate struct _Route: Monoid {
  var method: Method? = .get
  var path: [String] = []
  var query: [String: String] = [:]
  var body: Data? = nil

  static var empty = _Route()

  static func <>(lhs: _Route, rhs: _Route) -> _Route {
    return .init(
      method: lhs.method ?? rhs.method,
      path: lhs.path + rhs.path,
      query: lhs.query.merging(rhs.query, uniquingKeysWith: { a, _ in a }),
      // todo: is coalescing enough or should we be appending?
      body: lhs.body ?? rhs.body
    )
  }
}

// TODO: should this be generic over any monoid `M` instead of using `_Route` directly?
struct Router<A> {
  fileprivate let parse: (_Route) -> (rest: _Route, match: A)?
  fileprivate let print: (A) -> _Route?
  fileprivate let template: (A) -> _Route?

  public func match(_ request: URLRequest) -> A? {
    return (self <% _end).parse(route(from: request))?.match
  }

  public func request(for a: A) -> URLRequest? {
    return self.print(a).flatMap(request(from:))
  }

  public func templateRequest(for a: A) -> URLRequest? {
    return self.template(a).flatMap(request(from:))
  }
}

// Functor

extension Router {
  func map<B>(_ f: PartialIso<A, B>) -> Router<B> {
    return f <¢> self
  }

  static func <¢> <B> (lhs: PartialIso<A, B>, rhs: Router) -> Router<B> {
    return Router<B>(
      parse: { route in
        guard let (rest, match) = rhs.parse(route) else { return nil }
        return lhs.image(match).map { (rest, $0) }
      },
      print: lhs.preimage >-> rhs.print,
      template: lhs.preimage >-> rhs.template
    )
  }

  // TODO: how?
//  static func ¢> (lhs: Router<()>, rhs: A) -> Router {
//    fatalError()
//  }
}

// Applicative

extension Router {
  // todo: this form of applicative is right associative, but `<%>` is defined as infixl. maybe we should make
  // a right associative version and call it `<%>` or something?
  static func <%> <B> (lhs: Router, rhs: Router<B>) -> Router<(A, B)> {
    return Router<(A, B)>(
      parse: { str in
        guard let (more, a) = lhs.parse(str) else { return nil }
        guard let (rest, b) = rhs.parse(more) else { return nil }
        return (rest, (a, b))
      },
      print: { ab in
        let lhsPrint = lhs.print(ab.0)
        let rhsPrint = rhs.print(ab.1)
        return (curry(<>) <¢> lhsPrint <*> rhsPrint) ?? lhsPrint ?? rhsPrint
      },
      template: { ab in
        let lhsPrint = lhs.template(ab.0)
        let rhsPrint = rhs.template(ab.1)
        return (curry(<>) <¢> lhsPrint <*> rhsPrint) ?? lhsPrint ?? rhsPrint
    })
  }
}

extension Router where A == Prelude.Unit {
  static func <% <B>(x: Router<B>, y: Router) -> Router<B> {
    return PartialIso.unit.inverted <¢> (x <%> y) // <- this applicative is right associative
  }
}

extension Router {
  static func %> (x: Router<Prelude.Unit>, y: Router) -> Router {
    return (PartialIso.commute >>> PartialIso.unit.inverted) <¢> (x <%> y)
  }
}

// Alternative

extension Router {
  static func <|> (lhs: Router, rhs: Router) -> Router {
    return Router<A>(
      parse: { lhs.parse($0) ?? rhs.parse($0) },
      print: { lhs.print($0) ?? rhs.print($0) },
      template: { lhs.template($0) ?? rhs.template($0) }
    )
  }
}

extension Router {
  public static var empty: Router {
    return Router(
      parse: const(nil),
      print: const(nil),
      template: const(nil)
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
    print: { a in
      return _Route(method: nil, path: [str], query: [:], body: nil)
    },
    template: { a in
      return _Route(method: nil, path: [str], query: [:], body: nil)
  })
}

func pathComponent<A>(_ key: String, _ f: PartialIso<String, A>) -> Router<A> {
  return Router<A>(
    parse: { route in
      guard let (p, ps) = uncons(route.path), let v = f.image(p) else { return nil }
      return (_Route(method: route.method, path: ps, query: route.query, body: route.body), v)
    },
    print: { a in
      return .init(method: nil, path: [f.preimage(a) ?? ":\(key)"], query: [:], body: nil)
    },
    template: { a in
      return .init(method: nil, path: [":" + "\(A.self)".lowercased()], query: [:], body: nil)
  })
}

func param(_ key: String) -> Router<String> {
  return param(key, .id)
}

func param<A>(_ key: String, _ f: PartialIso<String, A>) -> Router<A> {
  return .init(
    parse: { route in
      guard let str = route.query[key] else { return nil }
      return f.image(str).map { (route, $0) }
  },
    print: { (a) -> _Route? in
      return _Route(method: nil, path: [], query: [key: f.preimage(a) ?? ""], body: nil)
  },
    template: { a in
      let typeString = "\(A.self)"
      let typeKey: String
      if typeString.contains("Optional<") {
        typeKey = "optional_\(typeString)"
          .replacingOccurrences(of: "Optional<", with: "")
          .replacingOccurrences(of: ">", with: "")
          .lowercased()
      } else {
        typeKey = typeString.lowercased()
      }

      return _Route(method: nil, path: [], query: [key: ":\(typeKey)"], body: nil)
  })
}

let _end = Router<Prelude.Unit>(
  parse: { route in
    guard route.path.isEmpty else { return nil }
    return (_Route(method: route.method, path: [], query: [:], body: nil), unit)
  },
  print: { _ in .empty },
  template: { _ in .empty }
)

extension Router {
  static var int: Router<Int> {
    return pathComponent("", intStringIso)
  }

  static var bool: Router<Bool> {
    return pathComponent("", boolStringIso)
  }

  static var str: Router<String> {
    return pathComponent("", .id)
  }

  static var num: Router<Double> {
    return pathComponent("", doubleStringIso)
  }
}

func params<A: Codable>() -> Router<A> {
  return Router<A>(
    parse: { route in
      (try? JSONSerialization.data(withJSONObject: route.query))
        .flatMap { try? JSONDecoder().decode(A.self, from: $0) }
        .map { (route, $0) }
  },
    print: { a in
      let params = (try? JSONEncoder().encode(a))
        .flatMap { try? JSONSerialization.jsonObject(with: $0) }
        .flatMap { $0 as? [String: Any] }
        .map { $0.mapValues { "\($0)" } }
        ?? [:]
      return _Route(method: nil, path: [], query: params, body: nil)
  },
    template: { a in
      let params = (try? JSONEncoder().encode(a))
        .flatMap { try? JSONSerialization.jsonObject(with: $0) }
        .flatMap { $0 as? [String: Any] }
        .map { $0.mapValues { _ in ":string" } }
        ?? [:]
      return _Route(method: nil, path: [], query: params, body: nil)
  })
}

func pure<A: Equatable>(_ a: A) -> Router<A> {
  return Router<A>(
    parse: { ($0, a) },
    print: { a == $0 ? .empty : nil },
    template: { a == $0 ? .empty : nil }
  )
}
func pure<A: Equatable>(_ a: A?) -> Router<A?> {
  return .init(
    parse: { ($0, a) },
    print: { a == $0 ? .empty : nil },
    template: { a == $0 ? .empty : nil }
  )
}

func opt<A: Equatable>(_ router: Router<A>) -> Router<A?> {
  let tmp = A?.iso.some <¢> router
  let tmp2: Router<A?> = pure(A?.none)
  return tmp <|> tmp2
}

extension Optional {
  enum iso {
    static var some: PartialIso<Wrapped, Wrapped?> {
      return PartialIso<Wrapped, Wrapped?>(
        image: { $0 },
        preimage: { $0 }
      )
    }
  }
}

let intStringIso = PartialIso<String, Int>(
  image: Int.init,
  preimage: String.init
)
let doubleStringIso = PartialIso<String, Double>(
  image: Double.init,
  preimage: String.init
)
let boolStringIso = PartialIso<String, Bool>(
  image: { $0 == "true" || $0 == "1" },
  preimage: { $0 ? "true" : "false" }
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

fileprivate func request(from route: _Route) -> URLRequest? {
  var components = URLComponents()
  components.path = route.path.joined(separator: "/")
  components.queryItems = route.query.map(URLQueryItem.init(name:value:))

  var request = components.url.map { URLRequest(url: $0) }
  request?.httpMethod = route.method?.rawValue
  request?.httpBody = route.body
  return request
}
