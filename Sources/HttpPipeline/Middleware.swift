import Foundation
import MediaType
import Optics
import Prelude

public typealias Middleware<I, J, E, F, A, B> = (Conn<I, E, A>) -> IO<Conn<J, F, B>>

public func writeStatus<E, A>(_ status: Status) -> Middleware<StatusLineOpen, HeadersOpen, E, E, A, A> {
  return pure <<< { conn in
    .init(
      data: conn.data,
      request: conn.request,
      response: conn.response |> \.status .~ status
    )
  }
}

public func writeHeader<E, A>(_ header: ResponseHeader) -> Middleware<HeadersOpen, HeadersOpen, E, E, A, A> {
  return pure <<< (\.response.headers %~ { $0 + [header] })
}

public func writeHeaders<E, A>(_ headers: [ResponseHeader]) -> Middleware<HeadersOpen, HeadersOpen, E, E, A, A> {
  return pure <<< (\.response.headers %~ { $0 + headers })
}

public func writeHeader<E, A>(_ name: String, _ value: String) -> Middleware<HeadersOpen, HeadersOpen, E, E, A, A> {
  return writeHeader(.other(name, value))
}

public func closeHeaders<E, A>(conn: Conn<HeadersOpen, E, A>) -> IO<Conn<BodyOpen, E, A>> {
  return pure <| .init(
    data: conn.data,
    request: conn.request,
    response: conn.response
  )
}

public func end<E>(conn: Conn<BodyOpen, E, Data>) -> IO<Conn<ResponseEnded, E, Data>> {
  switch conn.data {
  case .left:
    return pure <| .init(
      data: conn.data,
      request: conn.request,
      response: conn.response
    )
  case let .right(data):
    return pure <| .init(
      data: conn.data,
      request: conn.request,
      response: .init(
        status: conn.response.status,
        headers: conn.response.headers,
        body: data
      )
    )
  }
}

// TODO: rename to ignoreBody
public func end<E, A>(conn: Conn<HeadersOpen, E, A>) -> IO<Conn<ResponseEnded, E, Data>> {
  return conn
    |> closeHeaders
    >-> map(const(Data())) >>> pure
    >-> end
}

public func redirect<E, A>(
  to location: String,
  headersMiddleware: @escaping Middleware<HeadersOpen, HeadersOpen, E, E, A, A> = (id >>> pure)
  )
  ->
  Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data> {

    return writeStatus(.found)
      >-> headersMiddleware
      >-> writeHeader(.location(location))
      >-> end
}

public func send<E>(_ more: Data) -> Middleware<BodyOpen, BodyOpen, E, E, Data, Data> {
  return { conn in

    pure <| conn.flatMap { data in
      let concatenatedData = data + more

      return .init(
        data: .right(concatenatedData),
        request: conn.request,
        response: .init(
          status: conn.response.status,
          headers: conn.response.headers,
          body: concatenatedData
        )
      )
    }
  }
}

public func respond<E, A>(text: String) -> Middleware<HeadersOpen, ResponseEnded, E, E, A, Data> {
  return respond(body: text, contentType: .plain)
}

public func respond<E, A>(html: String) -> Middleware<HeadersOpen, ResponseEnded, E, E, A, Data> {
  return respond(body: html, contentType: .html)
}

public func respond<E, A>(json: String) -> Middleware<HeadersOpen, ResponseEnded, E, E, A, Data> {
  return respond(body: json, contentType: .json)
}

public func respond<E, A>(body: String, contentType: MediaType)
  -> Middleware<HeadersOpen, ResponseEnded, E, E, A, Data> {

    let data = Data(body.utf8)

    return map(const(data)) >>> pure
      >-> writeHeader(.contentType(contentType))
      >-> writeHeader(.contentLength(data.count))
      >-> closeHeaders
      >-> end
}
