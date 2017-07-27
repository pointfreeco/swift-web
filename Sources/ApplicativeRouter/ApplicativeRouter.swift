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

public enum Post {}
public enum Get {}

public typealias Route = (method: Method, path: [String], query: [String: String], body: Data?)

public struct Parser<A, Method> {
  fileprivate let parse: (Route) -> (rest: Route, match: A)?
}

// MARK: - Functor

extension Parser {
  public func map<B>(_ a2b: @escaping (A) -> B) -> Parser<B, Method> {
    return .init { route in
      guard let (rest, a) = self.parse(route) else { return nil }
      return (rest, a2b(a))
    }
  }

  public static func <¢> <B>(a2b: @escaping (A) -> B, pa: Parser) -> Parser<B, Method> {
    return pa.map(a2b)
  }

  public static func <¢ <B>(a: A, p: Parser<B, Method>) -> Parser {
    return const(a) <¢> p
  }

  public static func ¢> <B>(p: Parser<B, Method>, a: A) -> Parser {
    return const(a) <¢> p
  }
}

// MARK: - Apply

extension Parser {
  public static func <*> <B>(pa2b: Parser<(A) -> B, Method>, pa: Parser) -> Parser<B, Method> {
    return .init { route in
      guard let (more, a2b) = pa2b.parse(route) else { return nil }
      guard let (rest, a) = pa.parse(more) else { return nil }
      return (rest, a2b(a))
    }
  }

  public static func <* <B>(pa: Parser, pb: Parser<B, Method>) -> Parser {
    return const <¢> pa <*> pb
  }

  public static func *> <B>(pa: Parser, pb: Parser<B, Method>) -> Parser<B, Method> {
    return const(id) <¢> pa <*> pb
  }
}

// MARK: - Applicative

public func pure<A, Method>(_ a: A) -> Parser<A, Method> {
  return .init { route in
    (route, a)
  }
}

// MARK: - Alt

extension Parser {
  public static func <|> (lhs: Parser, rhs: Parser) -> Parser {
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

extension Parser {
  public static var end: Parser<(), Method> {
    return .init { route in
      guard route.path.isEmpty else { return nil }
      return ((method: route.method, path: [], query: [:], body: nil), ())
    }
  }

  public static func lit(_ string: String) -> Parser<(), Method> {
    return .init { route in
      guard let (p, ps) = uncons(route.path), p == string else { return nil }
      return ((route.method, ps, route.query, route.body), ())
    }
  }

  public static var num: Parser<Double, Method> {
    return .init { route in
      guard let (p, ps) = uncons(route.path), let n = Double(p) else { return nil }
      return ((route.method, ps, route.query, route.body), n)
    }
  }

  public static var int: Parser<Int, Method> {
    return .init { route in
      guard let (p, ps) = uncons(route.path), let n = Int(p) else { return nil }
      return ((route.method, ps, route.query, route.body), n)
    }
  }

  public static var str: Parser<String, Method> {
    return .init { route in
      guard let (p, ps) = uncons(route.path) else { return nil }
      return ((route.method, ps, route.query, route.body), p)
    }
  }

  public static func param(_ k: String) -> Parser<String, Method> {
    return .init { route in
      guard let v = route.query[k] else { return nil }
      return ((route.method, route.path, route.query, route.body), v)
    }
  }

  public static func opt<A, Method>(_ p: Parser<A, Method>) -> Parser<A?, Method> {
    return A?.some <¢> p <|> pure(.none)
  }

  // todo: make a `params` that works with decodable

  public static var params: Parser<[String: String], Method> {
    return .init { route in
      (route, route.query)
    }
  }

  public static var any: Parser<(), Method> {
    return .init { route in
      guard let (_, ps) = uncons(route.path) else { return nil }
      return ((route.method, ps, route.query, route.body), ())
    }
  }

  public static var many: Parser<(), Method> {
    return .init { route in
      ((route.method, [], route.query, route.body), ())
    }
  }

  public static func method<M>(_ method: ApplicativeRouter.Method) -> Parser<(), M> {
    return .init { route in
      guard route.method == method else { return nil }
      return (route, ())
    }
  }

  public static var get: Parser<(), Get> {
    return method(.get)
  }

  public static var post: Parser<(), Post> {
    return method(.post)
  }

  // todo: finish these
//  public let get = method(.get) <|> head
//  public let post = method(.post)
//  public let put = method(.put)
//  public let patch = method(.patch)
//  public let delete = method(.delete)
//  public let options = method(.options)
//  public let head = method(.head)

}

extension Parser where Method == Post {
  public static var dataBody: Parser<Data, Method> {
    return .init { route in
      route.body.map { (route, $0) }
    }
  }

  public static var stringBody: Parser<String, Method> {
    return .init { route in
      dataBody.parse(route).flatMap { route in
        String(data: route.match, encoding: .utf8).map { (route.rest, $0) }
      }
    }
  }
}

extension Parser where A: Decodable, Method == Post {
  public static var jsonBody: Parser<A, Method> {
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
