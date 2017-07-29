import Foundation
import Prelude

public enum Method: String {
  case get, post, put, patch, delete, options, head
}

extension Method {
  public init?(string: String) {
    self.init(rawValue: string.lowercased())
  }
}

public protocol HasBody {}

public enum Get {}
public enum Post: HasBody {}
public enum Put: HasBody {}
public enum Patch: HasBody {}
public enum Delete {}

public typealias Route = (method: Method, path: [String], query: [String: String], body: Data?)

public struct Parser<I, A> {
  fileprivate let parse: (Route) -> (rest: Route, match: A)?
}

// MARK: - Functor

extension Parser {
  public func map<B>(_ f: @escaping (A) -> B) -> Parser<I, B> {
    return .init { route in
      self.parse(route).map { ($0.rest, f($0.match)) }
    }
  }

  public static func <¢> <B>(f: @escaping (A) -> B, x: Parser) -> Parser<I, B> {
    return x.map(f)
  }

  public static func <¢ <B>(x: A, f: Parser<I, B>) -> Parser {
    return const(x) <¢> f
  }

  public static func ¢> <B>(f: Parser<I, B>, x: A) -> Parser {
    return const(x) <¢> f
  }
}

// MARK: - Apply

extension Parser {
  public static func <*> <B>(pf: Parser<I, (A) -> B>, px: Parser) -> Parser<I, B> {
    return .init { route in
      guard let (more, f) = pf.parse(route) else { return nil }
      guard let (rest, x) = px.parse(more) else { return nil }
      return (rest, f(x))
    }
  }

  public static func <* <B>(x: Parser, y: Parser<I, B>) -> Parser {
    return const <¢> x <*> y
  }

  public static func *> <B>(x: Parser, y: Parser<I, B>) -> Parser<I, B> {
    return const(id) <¢> x <*> y
  }
}

// MARK: - Applicative

public func pure<I, A>(_ x: A) -> Parser<I, A> {
  return .init { route in
    (route, x)
  }
}

// MARK: - Alt

extension Parser {
  public static func <|>(lhs: Parser, rhs: Parser) -> Parser {
    return .init { route in
      lhs.parse(route) ?? rhs.parse(route)
    }
  }
}

// MARK: - Plus

extension Parser {
  public static var empty: Parser {
    return Parser { _ in nil }
  }
}

// MARL: - Combinators

public func method<I>(_ method: Method) -> Parser<I, ()> {
  return .init { route in
    guard route.method == method else { return nil }
    return (route, ())
  }
}

public func lit<I>(_ string: String) -> Parser<I, ()> {
  return .init { route in
    guard let (p, ps) = uncons(route.path), p == string else { return nil }
    return ((route.method, ps, route.query, route.body), ())
  }
}

public func param<I>(_ k: String) -> Parser<I, String> {
  return .init { route in
    guard let v = route.query[k] else { return nil }
    return ((route.method, route.path, route.query, route.body), v)
  }
}

public func opt<I, A>(_ p: Parser<I, A>) -> Parser<I, A?> {
  return A?.some <¢> p <|> pure(.none)
}

extension Parser {
  public static var end: Parser<I, ()> {
    return .init { route in
      guard route.path.isEmpty else { return nil }
      return ((method: route.method, path: [], query: [:], body: nil), ())
    }
  }

  public static var num: Parser<I, Double> {
    return .init { route in
      guard let (p, ps) = uncons(route.path), let n = Double(p) else { return nil }
      return ((route.method, ps, route.query, route.body), n)
    }
  }

  public static var int: Parser<I, Int> {
    return .init { route in
      guard let (p, ps) = uncons(route.path), let n = Int(p) else { return nil }
      return ((route.method, ps, route.query, route.body), n)
    }
  }

  public static var str: Parser<I, String> {
    return .init { route in
      guard let (p, ps) = uncons(route.path) else { return nil }
      return ((route.method, ps, route.query, route.body), p)
    }
  }

  // TODO: make a `params` that works with decodable
  public static var params: Parser<I, [String: String]> {
    return .init { route in
      (route, route.query)
    }
  }

  public static var any: Parser<I, ()> {
    return .init { route in
      guard let (_, ps) = uncons(route.path) else { return nil }
      return ((route.method, ps, route.query, route.body), ())
    }
  }

  public static var many: Parser<I, ()> {
    return .init { route in
      ((route.method, [], route.query, route.body), ())
    }
  }

  public static var get: Parser<Get, ()> {
    return method(.get) <|> method(.head)
  }

  public static var post: Parser<Post, ()> {
    return method(.post)
  }

  public static var put: Parser<Put, ()> {
    return method(.put)
  }

  public static var patch: Parser<Patch, ()> {
    return method(.patch)
  }

  public static var delete: Parser<Delete, ()> {
    return method(.delete)
  }
}

extension Parser where I: HasBody {
  public static var dataBody: Parser<I, Data> {
    return .init { route in
      route.body.map { (route, $0) }
    }
  }

  public static var stringBody: Parser<I, String> {
    return .init { route in
      dataBody.parse(route).flatMap { route in
        String(data: route.match, encoding: .utf8).map { (route.rest, $0) }
      }
    }
  }
}

extension Parser where A: Decodable, I: HasBody {
  public static var jsonBody: Parser<I, A> {
    return .init { route in
      dataBody.parse(route).flatMap { route in
        let decoder = JSONDecoder()
        return (try? decoder.decode(A.self, from: route.match)).map { (route.rest, $0) }
      }
    }
  }
}

import Foundation

fileprivate func route(from request: URLRequest) -> Route {
  let method = request.httpMethod.flatMap(Method.init(string:)) ?? .get

  guard let components = request.url.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) })
  else { return (method, [], [:], request.httpBody) }

  let path = components.path.components(separatedBy: "/")
    |> mapOptional { $0.isEmpty ? nil : $0 }

  var query: [String: String] = [:]
  components.queryItems?.forEach { query[$0.name] = $0.value ?? "" }

  return (method, path, query, request.httpBody)
}

extension Parser {
  public func match(_ request: URLRequest) -> A? {
    return self.parse(route(from: request))?.match
  }
}
