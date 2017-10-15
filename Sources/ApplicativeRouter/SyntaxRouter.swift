import Foundation
import Prelude
import Optics

// todo: move to prelude: right associative applicative
infix operator <%>: infixr4
infix operator %>: infixr4
infix operator <%: infixr4

// todo: move to prelude
public func >-> <A, B, C>(lhs: @escaping (A) -> B?, rhs: @escaping (B) -> C?) -> (A) -> C? {
  return lhs >>> flatMap(rhs)
}

private struct RequestData: Monoid {
  var method: Method? = .get
  var path: [String] = []
  var query: [String: String] = [:]
  var body: Data? = nil

  static var empty = RequestData()

  static func <>(lhs: RequestData, rhs: RequestData) -> RequestData {
    return .init(
      method: lhs.method ?? rhs.method,
      path: lhs.path + rhs.path,
      query: lhs.query.merging(rhs.query, uniquingKeysWith: { $1 }),
      // todo: is coalescing enough or should we be appending?
      body: lhs.body ?? rhs.body
    )
  }
}

// TODO: should this be generic over any monoid `M` instead of using `_Route` directly?
// TODO: generic over an error semigroup too?
public struct Router<A> {
  fileprivate let parse: (RequestData) -> (rest: RequestData, match: A)?
  fileprivate let print: (A) -> RequestData?
  fileprivate let template: (A) -> RequestData?

  public func match(request: URLRequest) -> A? {
    return (self <% _end).parse(route(from: request))?.match
  }

  public func match(url: URL) -> A? {
    return match(request: URLRequest(url: url))
  }

  public func match(string: String) -> A? {
    return URL(string: string)
      .flatMap(match(url:))
  }

  public func request(for a: A) -> URLRequest? {
    return self.print(a).flatMap(request(from:))
  }

  public func url(for a: A) -> URL? {
    return self.print(a).flatMap(request(from:)).flatMap { $0.url }
  }

  public func templateRequest(for a: A) -> URLRequest? {
    return self.template(a).flatMap(request(from:))
  }

  public func templateUrl(for a: A) -> URL? {
    return self.templateRequest(for: a).flatMap { $0.url }
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

func const<A, B>(_ b: B) -> PartialIso<A, B> {
  return PartialIso<A, B>(
    image: const(b),
    preimage: const(nil)
  )
}

public func <¢ <A, B> (lhs: A, rhs: Router<B>) -> Router<A> {
  return const(lhs) <¢> rhs
}

// Apply

extension Router {
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
    return (PartialIso.commute >>> PartialIso.unit.inverted) <¢> x <%> y
  }
}

extension Router where A == Prelude.Unit {
  public static func <% <B>(x: Router<B>, y: Router) -> Router<B> {
    return PartialIso.unit.inverted <¢> x <%> y
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

// Plus

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

infix operator <=>: infixr9
public func <=> <A> (lhs: String, rhs: PartialIso<String, A>) -> Router<A> {
  return queryParam(lhs, rhs)
}

/// Parses and consumes a single path component matching the string provided.
public func lit(_ str: String) -> Router<Prelude.Unit> {
  return Router<Prelude.Unit>(
    parse: { route in
      guard let (_, ps) = uncons(route.path) else { return nil }
      return (RequestData(method: route.method, path: ps, query: route.query, body: route.body), unit)
    },
    print: { a in
      return RequestData(method: nil, path: [str], query: [:], body: nil)
    },
    template: { a in
      return RequestData(method: nil, path: [str], query: [:], body: nil)
  })
}

/// Parses and consumes a path component and tries to convert it to type `A` using the partial isomorphism
/// supplied.
public func pathParam<A>(_ f: PartialIso<String, A>) -> Router<A> {
  return Router<A>(
    parse: { route in
      guard let (p, ps) = uncons(route.path), let v = f.image(p) else { return nil }
      return (RequestData(method: route.method, path: ps, query: route.query, body: route.body), v)
  },
    print: { a in
      return .init(method: nil, path: [f.preimage(a) ?? ""], query: [:], body: nil)
  },
    template: { a in
      return .init(method: nil, path: [":\(typeKey(a))"], query: [:], body: nil)
  })
}

/// Parses (and does not consume) a query param keyed by `key`, and then tries to convert it to type `A`
/// using the partial isomorphism supplied.
public func queryParam<A>(_ key: String, _ f: PartialIso<String, A>) -> Router<A> {
  return .init(
    parse: { route in
      guard let str = route.query[key] else { return nil }
      return f.image(str).map { (route, $0) }
  },
    print: { a in
      return RequestData(method: nil, path: [], query: [key: f.preimage(a) ?? ""], body: nil)
  },
    template: { a in
      return RequestData(method: nil, path: [], query: [key: ":\(typeKey(a))"], body: nil)
  })
}

public func intQueryParam(_ key: String) -> Router<Int> {
  return queryParam(key, stringToInt)
}

public func stringQueryParam(_ key: String) -> Router<String> {
  return queryParam(key, .id)
}

public func numQueryParam(_ key: String) -> Router<Double> {
  return queryParam(key, stringToNum)
}

public func boolQueryParam(_ key: String) -> Router<Bool> {
  return queryParam(key, stringToBool)
}

/// Parses the body data of the request.
public let dataBody = Router<Data>(
  parse: { route in route.body.map { (route, $0) } },
  print: { .init(method: nil, path: [], query: [:], body: $0) },
  template: { .init(method: nil, path: [], query: [:], body: $0) }
)

/// Parses the body data of the request as a string.
public let stringBody = dataBody.map(stringToData.inverted)

/// Parses the body data of the request into form data of (key, value) pairs.
public let formDataBody = stringBody.map(stringToFormData)

public let jsonDictionaryToData = PartialIso<[String: String], Data>(
  image: { try? JSONSerialization.data(withJSONObject: $0) },
  preimage: {
    (try? JSONSerialization.jsonObject(with: $0))
      .flatMap { $0 as? [String: String] }
})

public func key<K, V>(_ key: K) -> PartialIso<[K: V], V> {
  return PartialIso<[K: V], V>(
    image: { $0[key] },
    preimage: { [key: $0] }
  )
}

public func keys<K, V>(_ keys: [K]) -> PartialIso<[K: V], [K: V]> {
  return .init(
    image: { $0.filter { key, _ in keys.contains(key) } },
    preimage: id
  )
}

public func formField(_ name: String) -> Router<String> {
  return formDataBody.map(key(name))
}

public func formFields(_ names: String...) -> Router<[String: String]> {
  return formDataBody.map(keys(names))
}

public func formDataBody<A: Codable>(_ type: A.Type) -> Router<A> {
  return ApplicativeRouter.formDataBody
    .map(jsonDictionaryToData >>> PartialIso.codableToDictionary.inverted)
}

/// Parses the body data of the request as JSON and then tries to decode the data into a value of type `A`.
public func jsonBody<A: Codable>(_ type: A.Type) -> Router<A> {
  return dataBody.map(PartialIso.codableToDictionary.inverted)
}

/// Parses the end of the request data by making sure that all of the path components have been consumed.
public let _end = Router<Prelude.Unit>(
  parse: { route in
    guard route.path.isEmpty else { return nil }
    return (RequestData(method: route.method, path: [], query: [:], body: nil), unit)
  },
  print: const(.empty),
  template: const(.empty)
)

extension Router {
  /// Parses and consumes a path component as an int.
  public static var int: Router<Int> { return pathParam(stringToInt) }

  /// Parses and consumes a path component as a bool.
  public static var bool: Router<Bool> { return pathParam(stringToBool) }

  /// Parses and consumes a path component as a string.
  public static var str: Router<String> { return pathParam(.id) }

  /// Parses and consumes a path component as a double.
  public static var num: Router<Double> { return pathParam(stringToNum) }
}

/// Parses the query params to create a value of type `A` via the `Codable` protocol.
/// TODO: this only works for types `A` with string fields. Is it possible to improve that?
public func queryParams<A: Codable>(_ type: A.Type) -> Router<A> {
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
      return RequestData(method: nil, path: [], query: params, body: nil)
  },
    template: { a in
      let params = (try? JSONEncoder().encode(a))
        .flatMap { try? JSONSerialization.jsonObject(with: $0) }
        .flatMap { $0 as? [String: Any] }
        .map { $0.mapValues { _ in ":string" } }
        ?? [:]
      return RequestData(method: nil, path: [], query: params, body: nil)
  })
}

/// Parses the HTTP method verb of the request.
public func method(_ method: Method) -> Router<Prelude.Unit> {
  return Router(
    parse: { route in
      guard route.method == method else { return nil }
      return (route, unit)
  },
    print: { _ in
      return .init(method: method, path: [], query: [:], body: nil)
  },
    template: { _ in
      return .init(method: method, path: [], query: [:], body: nil)
  })
}

public let delete = method(.delete)
public let get = method(.get)
public let head = method(.head)
public let options = method(.options)
public let patch = method(.patch)
public let post = method(.post)
public let put = method(.put)

private func route(from request: URLRequest) -> RequestData {
  let method = request.httpMethod.flatMap(Method.init(string:)) ?? .get

  guard let components = request.url.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) })
    else { return .init(method: method, path: [], query: [:], body: request.httpBody) }

  let path = components.path.components(separatedBy: "/")
    |> mapOptional { $0.isEmpty ? nil : $0 }

  var query: [String: String] = [:]
  components.queryItems?.forEach { query[$0.name] = $0.value ?? "" }

  return .init(method: method, path: path, query: query, body: request.httpBody)
}

private func request(from route: RequestData) -> URLRequest? {
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
