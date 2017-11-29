import Foundation
import Prelude
import Optics

/// Processes and consumes a single path component matching the string provided.
public func lit(_ str: String) -> Router<Prelude.Unit> {
  return Router<Prelude.Unit>(
    parse: { route in
      uncons(route.path)
        .flatMap { p, ps in
          p == str
            ? (.init(method: route.method, path: ps, query: route.query, body: route.body), unit)
            : nil
      }
  },
    print: { _ in .init(method: nil, path: [str], query: [:], body: nil) },
    template: { _ in .init(method: nil, path: [str], query: [:], body: nil) }
  )
}

/// Processes and consumes a path component and tries to convert it to type `A` using the partial isomorphism
/// supplied.
public func pathParam<A>(_ f: PartialIso<String, A>) -> Router<A> {
  return Router<A>(
    parse: { route in
      guard let (p, ps) = uncons(route.path), let v = f.apply(p) else { return nil }
      return (RequestData(method: route.method, path: ps, query: route.query, body: route.body), v)
  },
    print: { a in
      .init(method: nil, path: [f.unapply(a) ?? ""], query: [:], body: nil)
  },
    template: { a in
      .init(method: nil, path: [":\(typeKey(a))"], query: [:], body: nil)
  })
}

/// Processes (and does not consume) a query param keyed by `key`, and then tries to convert it to type `A`
/// using the partial isomorphism supplied.
///
/// - Parameters:
///   - key: The query param key to process.
///   - f: A partial iso from `String?` to `A`. Note that this partial iso takes optional strings so that
///        you can decide how to handle params that are not required.
public func queryParam<A>(_ key: String, _ f: PartialIso<String?, A>) -> Router<A> {
  return .init(
    parse: { route in
      return f.apply(route.query[key]).map { (route, $0) }
    },
    print: { a in
      var query: [String: String] = [:]
      if let str = f.unapply(a) {
        query[key] = str
      }
      return RequestData(method: nil, path: [], query: query, body: nil)
    },
    template: { a in
      RequestData(method: nil, path: [], query: [key: ":\(typeKey(a))"], body: nil)
  })
}

/// Processes (and does not consume) a query param keyed by `key`, and then tries to convert it to type `A`
/// using the partial isomorphism supplied.
public func queryParam<A>(_ key: String, _ f: PartialIso<String, A>) -> Router<A> {
  return queryParam(key, req(f))
}

/// Processes the body data of the request.
public let dataBody = Router<Data>(
  parse: { route in route.body.map { (route, $0) } },
  print: { .init(method: nil, path: [], query: [:], body: $0) },
  template: { .init(method: nil, path: [], query: [:], body: $0) }
)

/// Processes the body data of the request as a string.
public let stringBody = dataBody.map(PartialIso.data.inverted)

/// Processes the body data of the request into form data of (key, value) pairs.
public let formEncodedBodyFields = stringBody.map(.formEncodedFields)

public func formField(_ name: String) -> Router<String> {
  return formEncodedBodyFields.map(key(name))
}

public func formField<A>(_ name: String, _ f: PartialIso<String, A>) -> Router<A> {
  return formEncodedBodyFields.map(key(name)).map(f)
}

public func formFields(_ names: String...) -> Router<[String: String]> {
  return formEncodedBodyFields.map(keys(names))
}

public func formDataBody<A: Codable>(_ type: A.Type) -> Router<A> {
  return ApplicativeRouter.formEncodedBodyFields
    .map(jsonDictionaryToData >>> PartialIso.codableToData.inverted)
}

/// Parses the body data of the request as JSON and then tries to decode the data into a value of type `A`.
public func jsonBody<A: Codable>(_ type: A.Type) -> Router<A> {
  return dataBody.map(PartialIso.codableToData.inverted)
}

/// Parses the end of the request data by making sure that all of the path components have been consumed.
public let end = Router<Prelude.Unit>(
  parse: { route in
    route.path.isEmpty
      ? (RequestData(method: route.method, path: [], query: [:], body: nil), unit)
      : nil
},
  print: const(.empty),
  template: const(.empty)
)

extension Router {
  /// Parses and consumes a path component as an int.
  public static var int: Router<Int> { return pathParam(.int) }

  /// Parses and consumes a path component as a bool.
  public static var bool: Router<Bool> { return pathParam(.bool) }

  /// Parses and consumes a path component as a string.
  public static var string: Router<String> { return pathParam(.id) }

  /// Parses and consumes a path component as a double.
  public static var num: Router<Double> { return pathParam(.double) }
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
      route.method == method
        ? (route |> \.method .~ nil, unit)
        : nil
  },
    print: { _ in  .init(method: method, path: [], query: [:], body: nil) },
    template: { _ in  .init(method: method, path: [], query: [:], body: nil) }
  )
}

public let delete = method(.delete)
public let get = method(.get)
public let head = method(.head)
public let options = method(.options)
public let patch = method(.patch)
public let post = method(.post)
public let put = method(.put)

// MARK: - Private

private func typeKey<A>(_ a: A) -> String {
  // todo: convert camel case to snake case?
  let typeString = "\(type(of: a))"
  let typeKey: String
  if typeString.contains("Optional<") {
    typeKey = "optional_\(typeString)"
      .replacingOccurrences(of: "Optional<", with: "")
      .replacingOccurrences(of: ">", with: "")
      .lowercased()
  } else if typeString.contains("Either<") {
    typeKey = "\(typeString)"
      .replacingOccurrences(of: "Either<", with: "")
      .replacingOccurrences(of: ", ", with: "_or_")
      .replacingOccurrences(of: ">", with: "")
      .lowercased()
  } else {
    typeKey = typeString.lowercased()
  }

  return typeKey
}
