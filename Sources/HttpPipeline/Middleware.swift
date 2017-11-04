import Foundation
import MediaType
import Optics
import Prelude
import Either

public typealias Middleware<I, J, A, B, E> = (Conn<I, A>) -> IO<Conn<J, Either<E, B>>>

public func writeStatus<A, E>(_ status: Status) -> Middleware<StatusLineOpen, HeadersOpen, A, A, E> {
  return pure <<< { conn in
    .init(
      data: pure(conn.data),
      request: conn.request,
      response: conn.response |> \.status .~ status
    )
  }
}

public func writeHeader<A, E>(_ header: ResponseHeader) -> Middleware<HeadersOpen, HeadersOpen, A, A, E> {
  return pure <<< { conn in
    .init(
      data: pure(conn.data),
      request: conn.request,
      response: conn.response |> \.headers %~ { $0 + [header] }
    )
  }
}

public func writeHeaders<A, E>(_ headers: [ResponseHeader]) -> Middleware<HeadersOpen, HeadersOpen, A, A, E> {
  return pure <<< { conn in
    .init(
      data: pure(conn.data),
      request: conn.request,
      response: conn.response |> \.headers %~ { $0 + headers }
    )
  }
}

public func writeHeader<A, E>(_ name: String, _ value: String) -> Middleware<HeadersOpen, HeadersOpen, A, A, E> {
  return writeHeader(.other(name, value))
}

public func closeHeaders<A, E>(conn: Conn<HeadersOpen, A>) -> IO<Conn<BodyOpen, Either<E, A>>> {
  return pure <| .init(
    data: pure(conn.data),
    request: conn.request,
    response: conn.response
  )
}

public func end<E>(conn: Conn<BodyOpen, Data>) -> IO<Conn<ResponseEnded, Either<E, Data>>> {
  return pure <| .init(
    data: pure(conn.data),
    request: conn.request,
    response: Response(
      status: conn.response.status,
      headers: conn.response.headers,
      body: conn.data
    )
  )
}

// TODO: rename to ignoreBody
public func end<A>(conn: Conn<HeadersOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  let tmp = conn
    |> closeHeaders
    >-> map(const(Either<Error, Data>.right(Data()))) >>> pure
    >-> end

  return tmp
}

public func redirect<A>(
  to location: String,
  headersMiddleware: @escaping Middleware<HeadersOpen, HeadersOpen, A, A> = (id >>> pure)
  )
  ->
  Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return writeStatus(.found)
      >-> headersMiddleware
      >-> writeHeader(.location(location))
      >-> end
}

public func send(_ data: Data) -> Middleware<BodyOpen, BodyOpen, Data, Data> {
  return { conn in

    let concatenatedData = conn.data + data

    return pure <| .init(
      data: concatenatedData,
      request: conn.request,
      response: Response(
        status: conn.response.status,
        headers: conn.response.headers,
        body: concatenatedData
      )
    )
  }
}

public func respond<A>(text: String) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return respond(body: text, contentType: .plain)
}

public func respond<A>(html: String) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return respond(body: html, contentType: .html)
}

public func respond<A>(json: String) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return respond(body: json, contentType: .json)
}

public func respond<A>(body: String, contentType: MediaType)
  -> Middleware<HeadersOpen, ResponseEnded, A, Data> {

    let data = Data(body.utf8)

    return map(const(data)) >>> pure
      >-> writeHeader(.contentType(contentType))
      >-> writeHeader(.contentLength(data.count))
      >-> closeHeaders
      >-> end
}
