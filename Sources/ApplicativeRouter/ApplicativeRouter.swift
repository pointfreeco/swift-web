import Either
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
  public let parse: (Route) -> (rest: Route, match: A)?

  public init(parse: @escaping (Route) -> (rest: Route, match: A)?) {
    self.parse = parse
  }
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

// MARK: - Indexed

infix operator <*|: infixl4 // iapplyFirst

extension Parser {
  public static func <*| <J, B>(px: Parser, py: Parser<J, B>) -> Parser<J, A> {
    return .init { route in
      guard let (more, x) = px.parse(route) else { return nil }
      guard let (rest, _) = py.parse(more) else { return nil }
      return (rest, x)
    }
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

public func component<I, A>(_ f: @escaping (String) -> A?) -> Parser<I, A> {
  return .init { route in
    guard let (p, ps) = uncons(route.path), let v = f(p) else { return nil }
    return ((route.method, ps, route.query, route.body), v)
  }
}

public func method<I>(_ method: Method) -> Parser<I, ()> {
  return .init { route in
    guard route.method == method else { return nil }
    return (route, ())
  }
}

public func lit<I>(_ string: String) -> Parser<I, ()> {
  return component { $0 == string ? () : nil }
}

public func param<I, A>(_ k: String, _ p: Parser<I, A>) -> Parser<I, A> {
  return .init { route in
    guard let str = route.query[k] else { return nil }
    guard let (_, v) = p.parse((route.method, [str], [:], nil)) else { return nil }
    return ((route.method, route.path, route.query, route.body), v)
  }
}

public func param<I, A>(_ k: String, _ f: @escaping (String) -> A?) -> Parser<I, A> {
  return param(k, component(f))
}

public func param<I>(_ k: String) -> Parser<I, String> {
  return param(k, .str)
}

public func opt<I, A>(_ p: Parser<I, A>) -> Parser<I, A?> {
  return A?.some <¢> p <|> pure(.none)
}

public func either<I, L, R>(_ l: Parser<I, L>, _ r: Parser<I, R>) -> Parser<I, Either<L, R>> {
  return l.map(Either.left) <|> r.map(Either.right)
}

public let end = Parser<(), ()> { route in
  guard route.path.isEmpty else { return nil }
  return ((method: route.method, path: [], query: [:], body: nil), ())
}

extension Parser {
  public static var num: Parser<I, Double> {
    return component(Double.init)
  }

  public static var int: Parser<I, Int> {
    return component { Int($0) }
  }

  public static var str: Parser<I, String> {
    return component(id)
  }

  // TODO: make a `params` that works with decodable
  public static var params: Parser<I, [String: String]> {
    return .init { route in
      (route, route.query)
    }
  }

  public static var any: Parser<I, ()> {
    return component(const(()))
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

  public static var formData: Parser<I, [String: String]> {
    return self.stringBody.map { body in
      let pairs = body.split(separator: "&")
        .map {
          $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            .flatMap(String.init >>> Prelude.get(\.removingPercentEncoding))
        }
        .map { ($0[0], $0[1]) }
      return [String: String](uniqueKeysWithValues: pairs)
    }
  }

  public static func formField(_ name: String) -> Parser<I, String> {
    return formField(name, str)
  }

  public static func formField<A>(_ name: String, _ p: Parser<I, A>) -> Parser<I, A> {
    return .init { route in
      guard let (rest, formData) = Parser.formData.parse(route), let str = formData[name] else { return nil }
      guard let (_, v) = p.parse((route.method, [str], [:], nil)) else { return nil }
      return (rest, v)
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
