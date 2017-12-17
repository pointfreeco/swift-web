import Foundation
import Prelude
import Optics
import UrlFormEncoding

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
    print: { _ in .init(method: nil, path: [str], query: nil, body: nil) },
    template: { _ in .init(method: nil, path: [str], query: nil, body: nil) }
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
      .init(method: nil, path: [f.unapply(a) ?? ""], query: nil, body: nil)
  },
    template: { a in
      .init(method: nil, path: [":\(typeKey(a))"], query: nil, body: nil)
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
      return f.apply(route.params[key]).map { (route, $0) }
    },
    print: { a in
      let params = f.unapply(a).flatMap { $0.map { [key: $0] } }
      return RequestData(method: nil, path: [], query: params.map(print(params:)), body: nil)
    },
    template: { a in
      RequestData(method: nil, path: [], query: print(params: [key: ":\(typeKey(a))"]), body: nil)
  })
}

private func print(params: [String: String]) -> String {
  return params
    .flatMap {
      curry { $0 + "=" + $1 }
        <¢> $0.addingPercentEncoding(withAllowedCharacters: .urlQueryParamAllowed)
        <*> $1.addingPercentEncoding(withAllowedCharacters: .urlQueryParamAllowed)
    }
    .joined(separator: "&")
}

/// Processes (and does not consume) a query param keyed by `key`, and then tries to convert it to type `A`
/// using the partial isomorphism supplied.
public func queryParam<A>(_ key: String, _ f: PartialIso<String, A>) -> Router<A> {
  return queryParam(key, req(f))
}

/// Parses the query params to create a value of type `A` via the `Codable` protocol.
public func queryParams<A: Codable>(_ type: A.Type, decoder: UrlFormDecoder = .init())
  -> Router<A> {

    return .init(
      parse: { route in
        (try? decoder.decode(A.self, from: route.query.map(^\.utf8 >>> Data.init) ?? .init()))
          .map { (route, $0) }
    },
      print: { a in
        let params = (try? JSONEncoder().encode(a))
          .flatMap { try? JSONSerialization.jsonObject(with: $0) }
          .flatMap { $0 as? [String: Any] }
          .map { $0.map { "\($0)=\($1)" }.joined(separator: "&") }
        return RequestData(method: nil, path: [], query: params, body: nil)
    },
      template: { a in
        let params = (try? JSONEncoder().encode(a))
          .flatMap { try? JSONSerialization.jsonObject(with: $0) } // FIXME: build/use a UrlFormEncoder
          .flatMap { $0 as? [String: Any] }
          .map { $0.map { k, v in "\(k)=:\(typeKey(v))" }.joined(separator: "&") }
        return RequestData(method: nil, path: [], query: params, body: nil)
    })
}

/// Processes the body data of the request.
public let dataBody = Router<Data>(
  parse: { route in route.body.map { (route, $0) } },
  print: { .init(method: nil, path: [], query: nil, body: $0) },
  template: { .init(method: nil, path: [], query: nil, body: $0) }
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

public func formBody<A: Codable>(_ type: A.Type, decoder: UrlFormDecoder = .init()) -> Router<A> {
  return dataBody.map(PartialIso.codableToFormData(type, decoder: decoder).inverted)
}

/// Parses the body data of the request as JSON and then tries to decode the data into a value of type `A`.
public func jsonBody<A: Codable>(
  _ type: A.Type,
  encoder: JSONEncoder = .init(),
  decoder: JSONDecoder = .init()
  )
  -> Router<A> {

    return dataBody.map(PartialIso.codableToJsonData(type, encoder: encoder, decoder: decoder).inverted)
}

/// Parses the end of the request data by making sure that all of the path components have been consumed.
public let end = Router<Prelude.Unit>(
  parse: { route in
    route.path.isEmpty
      ? (RequestData(method: route.method, path: [], query: nil, body: nil), unit)
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

/// Parses the HTTP method verb of the request.
public func method(_ method: Method) -> Router<Prelude.Unit> {
  return Router(
    parse: { route in
      route.method == method
        ? (route |> \.method .~ nil, unit)
        : nil
  },
    print: { _ in  .init(method: method, path: [], query: nil, body: nil) },
    template: { _ in  .init(method: method, path: [], query: nil, body: nil) }
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

private func typeKey(_ a: Any) -> String {
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
