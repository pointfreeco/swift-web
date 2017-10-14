import Foundation
import Prelude
import Optics

// todo: move to prelude: right associative applicative
infix operator <%>: infixr4
infix operator %>: infixr4
infix operator <%: infixr4

// todo: move to prelude
public func >-> <A, B, C>(lhs: @escaping (A) -> B?, rhs: @escaping (B) -> C?) -> (A) -> C? {
  return { a in lhs(a).flatMap(rhs) }
}

private struct _Route: Monoid {
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
public struct Router<A> {
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
  public func map<B>(_ f: PartialIso<A, B>) -> Router<B> {
    return f <¢> self
  }

  public static func <¢> <B> (lhs: PartialIso<A, B>, rhs: Router) -> Router<B> {
    return Router<B>(
      parse: { route in
        guard let (rest, match) = rhs.parse(route) else { return nil }
        return lhs.image(match).map { (rest, $0) }
      },
      print: lhs.preimage >-> rhs.print,
      template: lhs.preimage >-> rhs.template
    )
  }
}

// Applicative

extension Router {
  // todo: this form of applicative is right associative, but `<%>` is defined as infixl. maybe we should make
  // a right associative version and call it `<%>` or something?
  public static func <%> <B> (lhs: Router, rhs: Router<B>) -> Router<(A, B)> {
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

  public static func %> (x: Router<Prelude.Unit>, y: Router) -> Router {
    return (PartialIso.commute >>> PartialIso.unit.inverted) <¢> (x <%> y)
  }
}

extension Router where A == Prelude.Unit {
  public static func <% <B>(x: Router<B>, y: Router) -> Router<B> {
    return PartialIso.unit.inverted <¢> (x <%> y) // <- this applicative is right associative
  }
}

// Alternative

extension Router {
  public static func <|> (lhs: Router, rhs: Router) -> Router {
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

public func lit(_ str: String) -> Router<Prelude.Unit> {
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

public func pathComponent<A>(_ key: String, _ f: PartialIso<String, A>) -> Router<A> {
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

public func param(_ key: String) -> Router<String> {
  return param(key, .id)
}

public func param<A>(_ key: String, _ f: PartialIso<String, A>) -> Router<A> {
  return .init(
    parse: { route in
      guard let str = route.query[key] else { return nil }
      return f.image(str).map { (route, $0) }
  },
    print: { (a) -> _Route? in
      return _Route(method: nil, path: [], query: [key: f.preimage(a) ?? ""], body: nil)
  },
    template: { a in
      return _Route(method: nil, path: [], query: [key: ":\(typeKey(a))"], body: nil)
  })
}

public let _end = Router<Prelude.Unit>(
  parse: { route in
    guard route.path.isEmpty else { return nil }
    return (_Route(method: route.method, path: [], query: [:], body: nil), unit)
  },
  print: { _ in .empty },
  template: { _ in .empty }
)

extension Router {
  public static var int: Router<Int> {
    return pathComponent("", stringToInt)
  }

  public static var bool: Router<Bool> {
    return pathComponent("", stringToBool)
  }

  public static var str: Router<String> {
    return pathComponent("", .id)
  }

  public static var num: Router<Double> {
    return pathComponent("", stringToNum)
  }
}

extension Router where A: Codable {
  public static var params: Router {
    return .init(
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
}

private func route(from request: URLRequest) -> _Route {
  let method = request.httpMethod.flatMap(Method.init(string:)) ?? .get

  guard let components = request.url.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) })
    else { return _Route(method: method, path: [], query: [:], body: request.httpBody) }

  let path = components.path.components(separatedBy: "/")
    |> mapOptional { $0.isEmpty ? nil : $0 }

  var query: [String: String] = [:]
  components.queryItems?.forEach { query[$0.name] = $0.value ?? "" }

  return _Route.init(method: method, path: path, query: query, body: request.httpBody)
}

private func request(from route: _Route) -> URLRequest? {
  var components = URLComponents()
  components.path = route.path.joined(separator: "/")
  components.queryItems = route.query.map(URLQueryItem.init(name:value:))

  var request = components.url.map { URLRequest(url: $0) }
  request?.httpMethod = route.method?.rawValue
  request?.httpBody = route.body
  return request
}

private func typeKey<A>(_ a: A) -> String {
  let typeString = "\(type(of: a))"
  let typeKey: String
  if typeString.contains("Optional<") {
    typeKey = "optional_\(typeString)"
      .replacingOccurrences(of: "Optional<", with: "")
      .replacingOccurrences(of: ">", with: "")
      .lowercased()
  } else {
    typeKey = typeString.lowercased()
  }

  return typeKey
}
