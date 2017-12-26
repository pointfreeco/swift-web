import Foundation
import MediaType
import Optics
import Prelude

public typealias Middleware<I, J, A, B> = (Conn<I, A>) -> IO<Conn<J, B>>

public func >¢< <A, B, C, I, J>(
  lhs: @escaping (A) -> C,
  rhs: @escaping Middleware<I, J, C, B>
  )
  -> Middleware<I, J, A, B> {

    return map(lhs) >>> rhs
}

public func writeStatus<A>(_ status: Status) -> Middleware<StatusLineOpen, HeadersOpen, A, A> {
  return pure <<< { conn in
    .init(
      data: conn.data,
      request: conn.request,
      response: conn.response |> \.status .~ status
    )
  }
}

public func writeHeader<A>(_ header: ResponseHeader) -> Middleware<HeadersOpen, HeadersOpen, A, A> {
  return pure <<< (\.response.headers %~ { $0 + [header] })
}

public func writeHeaders<A>(_ headers: [ResponseHeader]) -> Middleware<HeadersOpen, HeadersOpen, A, A> {
  return pure <<< (\.response.headers %~ { $0 + headers })
}

public func writeHeader<A>(_ name: String, _ value: String) -> Middleware<HeadersOpen, HeadersOpen, A, A> {
  return writeHeader(.other(name, value))
}

public func closeHeaders<A>(conn: Conn<HeadersOpen, A>) -> IO<Conn<BodyOpen, A>> {
  return pure <| .init(
    data: conn.data,
    request: conn.request,
    response: conn.response
  )
}

public func end(conn: Conn<BodyOpen, Data>) -> IO<Conn<ResponseEnded, Data>> {
  return pure <| .init(
    data: conn.data,
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
  return conn
    |> closeHeaders
    >-> map(const(Data())) >>> pure
    >-> end
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
