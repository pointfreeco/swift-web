import Prelude

public enum Method: String {
  case get, post, put, patch, delete, options, head
}

extension Method {
  public init?(string: String) {
    self.init(rawValue: string.lowercased())
  }
}

public typealias Route = (method: Method, path: [String], query: [String: String])

public struct Parser<A> {
  fileprivate let parse: (Route) -> (rest: Route, match: A)?
}

extension Parser { // : Functor
  public func map<B>(_ a2b: @escaping (A) -> B) -> Parser<B> {
    return Parser<B> { route in
      guard let (rest, a) = self.parse(route) else { return nil }
      return (rest, a2b(a))
    }
  }

  public static func <¢> <B>(a2b: @escaping (A) -> B, pa: Parser) -> Parser<B> {
    return pa.map(a2b)
  }

  public static func <¢ (a: A, p: Parser<()>) -> Parser {
    return const(a) <¢> p
  }
}

extension Parser { // : Alt
  public static func <|> (lhs: Parser, rhs: Parser) -> Parser { // : Alt
    return Parser<A> { route in
      lhs.parse(route) ?? rhs.parse(route)
    }
  }
}

extension Parser { // : Apply
  public static func <*> <B>(pa2b: Parser<(A) -> B>, pa: Parser) -> Parser<B> { // : Apply
    return Parser<B> { route in
      guard let (more, a2b) = pa2b.parse(route) else { return nil }
      guard let (rest, a) = pa.parse(more) else { return nil }
      return (rest, a2b(a))
    }
  }

  public static func <* <B>(pa: Parser, pb: Parser<B>) -> Parser {
    return const <¢> pa <*> pb
  }

  public static func *> <B>(pa: Parser, pb: Parser<B>) -> Parser<B> {
    return const(id) <¢> pa <*> pb
  }
}

extension Parser { // : Plus
  public static var empty: Parser {
    return Parser { _ in nil }
  }
}

public func pure<A>(_ a: A) -> Parser<A> { // : Applicative
  return Parser<A> { route in
    (route, a)
  }
}

public let end = Parser<()> { route in
  guard route.path.isEmpty else { return nil }
  return ((method: route.method, path: [], query: [:]), ())
}

public func lit(_ string: String) -> Parser<()> {
  return Parser<()> { route in
    guard let (p, ps) = uncons(route.path), p == string else { return nil }
    return ((route.method, ps, route.query), ())
  }
}

public let num = Parser<Double> { route in
  guard let (p, ps) = uncons(route.path), let n = Double(p) else { return nil }
  return ((route.method, ps, route.query), n)
}

public let int = Parser<Int> { route in
  guard let (p, ps) = uncons(route.path), let n = Int(p) else { return nil }
  return ((route.method, ps, route.query), n)
}

public let str = Parser<String> { route in
  guard let (p, ps) = uncons(route.path) else { return nil }
  return ((route.method, ps, route.query), p)
}

public func param(_ k: String) -> Parser<String> {
  return Parser<String> { route in
    guard let v = route.query[k] else { return nil }
    return ((route.method, route.path, route.query), v)
  }
}

public func opt<A>(_ p: Parser<A>) -> Parser<A?> {
  return A?.some <¢> p <|> pure(.none)
}

public let params = Parser<[String: String]> { route in
  return (route, route.query)
}

public let any = Parser<()> { route in
  guard let (_, ps) = uncons(route.path) else { return nil }
  return ((route.method, ps, route.query), ())
}

public let many = Parser<()> { route in
  ((route.method, [], route.query), ())
}

public func method(_ method: Method) -> Parser<()> {
  return Parser<()> { route in
    guard route.method == method else { return nil }
    return (route, ())
  }
}

public let get = method(.get) <|> head
public let post = method(.post)
public let put = method(.put)
public let patch = method(.patch)
public let delete = method(.delete)
public let options = method(.options)
public let head = method(.head)

import Foundation

fileprivate func route(from request: URLRequest) -> Route {
  let method = request.httpMethod.flatMap(Method.init(string:)) ?? .get

  guard let components = request.url.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) })
  else { return (method, [], [:]) }

  let path = components.path
    .components(separatedBy: "/")
    .flatMap { $0.isEmpty ? nil : $0 } // bad flatMap, bad

  var query: [String: String] = [:]
  components.queryItems?.forEach { query[$0.name] = $0.value ?? "" }

  return (method, path, query)
}

extension Parser {
  public func match(_ request: URLRequest) -> A? {
    return self.parse(route(from: request))?.match
  }
}
