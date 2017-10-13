import Foundation
import Prelude
import Optics

public func >-> <A, B, C>(lhs: @escaping (A) -> B?, rhs: @escaping (B) -> C?) -> (A) -> C? {
  return { a in lhs(a).flatMap(rhs) }
}

struct Iso<A, B> {
  let image: (A) -> B?
  let preimage: (B) -> A?

  var inverted: Iso<B, A> {
    return .init(image: self.preimage, preimage: self.image)
  }

  static var commute: Iso<(A, B), (B, A)> {
    return Iso<(A, B), (B, A)>(
      image: { ($1, $0) },
      preimage: { ($1, $0) }
    )
  }

  static func >>> <C> (lhs: Iso<A, B>, rhs: Iso<B, C>) -> Iso<A, C> {
    return Iso<A, C>(
      image: lhs.image >-> rhs.image,
      preimage: rhs.preimage >-> lhs.preimage
    )
  }

  static var id: Iso<A, A> {
    return Iso<A, A>(image: { $0 }, preimage: { $0 })
  }
}

extension Iso where B == (A, Void) {
  static var unit: Iso<A, (A, Void)> {
    return Iso<A, (A, Void)>(
      image: { ($0, ()) },
      preimage: { $0.0 }
    )
  }
}

//public typealias Route = (method: Method, path: [String], query: [String: String], body: Data?)
struct _Request {

}

struct Router<A> {
  let parse: (Route) -> (rest: Route, match: A)?
  let print: (A) -> String?
}

// Functor

extension Router {
  static func <¢> <B> (lhs: Iso<A, B>, rhs: Router) -> Router<B> {
    return Router<B>(
      parse: { route in
        guard let (rest, match) = rhs.parse(route) else { return nil }
        return lhs.image(match).map { (rest, $0) }
      },
      print: { b in lhs.preimage(b).flatMap(rhs.print) }
    )
  }

  // TODO: how?
//  static func ¢> (lhs: Router<()>, rhs: A) -> Router {
//    fatalError()
//  }
}

// Applicative

extension Router {
  static func <*> <B> (lhs: Router, rhs: Router<B>) -> Router<(A, B)> {
    return Router<(A, B)>(
      parse: { str in
        Swift.print(lhs.parse(str))
        return lhs.parse(str).flatMap { more, a in
          Swift.print(rhs.parse(more))
          return rhs.parse(more).map { rest, b in
            //Swift.print(rest)
            Swift.print(a)
            Swift.print(b)
            return (rest, (a, b))
          }
        }
    },
      print: { ab in
        curry(+) <¢> lhs.print(ab.0) <*> rhs.print(ab.1)
    })
  }
}

extension Router where A == () {

  static func <* <B>(x: Router<B>, y: Router) -> Router<B> {
    return Iso.unit.inverted <¢> (x <*> y) // <- this applicative is right associative
  }
}

extension Router {
  static func *> (x: Router<()>, y: Router) -> Router {
    return (Iso.unit >>> Iso.commute).inverted <¢> (x <*> y)
  }
}

func pure<A: Equatable>(_ a: A) -> Router<A> {
  return Router<A>(
    parse: { ($0, a) },
    print: { a == $0 ? "" : nil }
  )
}

// Alternative

extension Router {
  static func <|> (lhs: Router, rhs: Router) -> Router {
    return Router<A>(
      parse: { lhs.parse($0) ?? rhs.parse($0) },
      print: { lhs.print($0) ?? rhs.print($0) }
    )
  }
}

extension Router {
  public static var empty: Router {
    return Router(
      parse: { _ in nil },
      print: { _ in "" }
    )
  }
}

// Combinators

func lit(_ str: String) -> Router<()> {
  return Router<()>(
    parse: { route in
      guard let (_, ps) = uncons(route.path) else { return nil }
      return ((route.method, ps, route.query, route.body), ())
    },
    print: { a in
      return "/\(str)"
  })
}

func pathComponent<A>(_ key: String, _ f: Iso<String, A>) -> Router<A> {
  return Router<A>(
    parse: { route in
      guard let (p, ps) = uncons(route.path), let v = f.image(p) else { return nil }
      return ((route.method, ps, route.query, route.body), v)
    },
    print: { a in
      "/" + (f.preimage(a) ?? ":\(key)")
  })
}

let _end = Router<()>(
  parse: { route in
    guard route.path.isEmpty else { return nil }
    return ((method: route.method, path: [], query: [:], body: nil), ())
  },
  print: { _ in "" }
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



//public func component<I, A>(_ f: @escaping (String) -> A?) -> Parser<I, A> {
//  return .init { route in
//    guard let (p, ps) = uncons(route.path), let v = f(p) else { return nil }
//    return ((route.method, ps, route.query, route.body), v)
//  }
//}


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

extension Router {
  public func match(_ request: URLRequest) -> A? {
    return self.parse(route(from: request))?.match
  }
}
