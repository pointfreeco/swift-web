import Foundation
import Prelude

public typealias Middleware<I, J, A, B> = (Conn<I, A>) -> Conn<J, B>

public func writeStatus<Data>(_ status: Status) -> Middleware<StatusLineOpen, HeadersOpen, Data, Data> {
  return { connection in
    return .init(
      data: connection.data,
      request: connection.request,
      response: Response(status: status, headers: connection.response.headers, body: nil)
    )
  }
}

public func writeHeader<Data>(_ header: ResponseHeader) -> Middleware<HeadersOpen, HeadersOpen, Data, Data> {
  return { conn in
    .init(
      data: conn.data,
      request: conn.request,
      response: Response(
        status: conn.response.status,
        headers: conn.response.headers + [header], body: nil
      )
    )
  }
}

public func writeHeader<Data>(_ name: String, _ value: String) -> Middleware<HeadersOpen, HeadersOpen, Data, Data> {
  return writeHeader(.other(name, value))
}

public func closeHeaders<Data>() -> Middleware<HeadersOpen, BodyOpen, Data, Data> {
  return { conn in
    .init(
      data: conn.data,
      request: conn.request,
      response: conn.response
    )
  }
}

public let end: Middleware<BodyOpen, ResponseEnded, Data?, Data?> =
  { conn in
    .init(
      data: conn.data,
      request: conn.request,
      response: Response(
        status: conn.response.status,
        headers: conn.response.headers,
        body: conn.data
      )
    )
}

public func redirect<Data>(_ location: String) -> Middleware<StatusLineOpen, HeadersOpen, Data, Data> {
  return writeStatus(.found)
    >>> writeHeader("Location", location)
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
    // TODO: should `conn.data` be var?
    var responseData = conn.data
    if let data = data {
      responseData?.append(data)
    }
    return .init(
      data: conn.data,
      request: conn.request,
      response: Response(
        status: conn.response.status,
        headers: conn.response.headers,
        body: responseData
      )
    )
  }
}

public func respond<A>(text: String) -> Middleware<HeadersOpen, ResponseEnded, A, Data?> {
  return { conn in
    conn.map(const(text.data(using: .utf8)))
      |> writeHeader(.contentType(.text))
      |> closeHeaders()
      |> end
  }
}

public func respond<A>(html: String) -> Middleware<HeadersOpen, ResponseEnded, A, Data?> {
  return { conn in
    conn.map(const(html.data(using: .utf8)))
      |> writeHeader(.contentType(.html))
      |> closeHeaders()
      |> end
  }
}

public func respond<A>(json: String) -> Middleware<HeadersOpen, ResponseEnded, A, Data?> {
  return { conn in
    conn.map(const(json.data(using: .utf8)))
      |> writeHeader(.contentType(.json))
      |> closeHeaders()
      |> end
  }
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
