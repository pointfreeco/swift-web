import Foundation
import MediaType
import Optics
import Prelude

public typealias Middleware<I, J, A, B> = (Conn<I, A>) -> Conn<J, B>

public func writeStatus<A>(_ status: Status) -> Middleware<StatusLineOpen, HeadersOpen, A, A> {
  return { conn in
    .init(
      data: conn.data,
      request: conn.request,
      response: Response(
        status: status,
        headers: conn.response.headers,
        body: nil
      )
    )
  }
}

public func writeHeader<A>(_ header: ResponseHeader) -> Middleware<HeadersOpen, HeadersOpen, A, A> {
  return \.response.headers %~ { $0 + [header] }
}

public func writeHeader<A>(_ name: String, _ value: String) -> Middleware<HeadersOpen, HeadersOpen, A, A> {
  return writeHeader(.other(name, value))
}

public func closeHeaders<A>(conn: Conn<HeadersOpen, A>) -> Conn<BodyOpen, A> {
  return .init(
    data: conn.data,
    request: conn.request,
    response: conn.response
  )
}

public func end(conn: Conn<BodyOpen, Data?>) -> Conn<ResponseEnded, Data?> {
  return .init(
    data: conn.data,
    request: conn.request,
    response: Response(
      status: conn.response.status,
      headers: conn.response.headers,
      body: conn.data
    )
  )
}

public func end<A>(conn: Conn<HeadersOpen, A>) -> Conn<ResponseEnded, Data?> {
  return conn
    |> closeHeaders
    |> map(const(nil))
    |> end
}

public func redirect<A>(
  to location: String,
  headersMiddleware: @escaping Middleware<HeadersOpen, HeadersOpen, A, A> = id
  )
  ->
  Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return writeStatus(.found)
      >>> headersMiddleware
      >>> writeHeader(.location(location))
      >>> map(const(nil))
      >>> closeHeaders
      >>> end
}

public func basicAuth<A>(user: String, password: String)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { middleware in
      { conn in
        if validateBasicAuth(user: user, password: password, request: conn.request) {
          return middleware(conn)
        }

        return conn |>
          (
            writeStatus(.unauthorized)
              >>> writeHeader("WWW-Authenticate", "Basic")
              >>> respond(text: "Please authenticate.")
        )
      }
    }
}

public func send(_ data: Data?) -> Middleware<BodyOpen, BodyOpen, Data?, Data?> {
  return { conn in

    var concatenatedData = conn.data
    if let data = data {
      concatenatedData?.append(data)
    }

    return .init(
      data: conn.data,
      request: conn.request,
      response: Response(
        status: conn.response.status,
        headers: conn.response.headers,
        body: concatenatedData
      )
    )
  }
}

public func respond<A>(text: String) -> Middleware<HeadersOpen, ResponseEnded, A, Data?> {
  return respond(body: text, contentType: .plain)
}

public func respond<A>(html: String) -> Middleware<HeadersOpen, ResponseEnded, A, Data?> {
  return respond(body: html, contentType: .html)
}

public func respond<A>(json: String) -> Middleware<HeadersOpen, ResponseEnded, A, Data?> {
  return respond(body: json, contentType: .json)
}

public func respond<A>(body: String, contentType: MediaType)
  -> Middleware<HeadersOpen, ResponseEnded, A, Data?> {
    let data = body.data(using: .utf8)
    return map(const(data))
      >>> writeHeader(.contentType(contentType))
      >>> writeHeader(.contentLength(data?.count ?? 0))
      >>> closeHeaders
      >>> end
}

public func notFound<A>(_ middleware: @escaping Middleware<HeadersOpen, ResponseEnded, A, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {
    return writeStatus(.notFound)
      >>> middleware
}

public func validateBasicAuth(user: String, password: String, request: URLRequest) -> Bool {

  let auth = request.allHTTPHeaderFields?.first(where: { $0.key == "Authorization" })?.value ?? ""

  let parts = Foundation.Data(base64Encoded: String(auth.dropFirst(6)))
    .flatMap { String(data: $0, encoding: .utf8) }
    .map { $0.split(separator: ":").map(String.init) }

  return parts?.first == .some(user) && parts?.last == .some(password)
}

public func contentLength<A, B>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, B>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, A, B> {

    return { conn in
      let nextConn = middleware(conn)
      return nextConn
        |> \.response.headers %~ {
          $0 + [.contentLength(nextConn.response.body?.count ?? 0)]
      }
    }
}

