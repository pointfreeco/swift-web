import Prelude
import Html
import NIO
import NIOHTTP1

public typealias Middleware<I, J, A, B> = (Conn<I, A>) -> EventLoopFuture<Conn<J, B>>

public typealias AppMiddleware = Middleware<StatusLineOpen, ResponseEnded, Void, Void>

public func writeStatus<A>(_ status: HTTPResponseStatus) -> Middleware<StatusLineOpen, HeadersOpen, A, A> {
  return { conn in
    var conn = conn.transition(to: HeadersOpen.self)
    conn.response.head.status = status
    return conn.channel.eventLoop.makeSucceededFuture(conn)
  }
}

public func head<A>(_ status: HTTPResponseStatus) -> Middleware<StatusLineOpen, ResponseEnded, A, Void> {
  return writeStatus(status) >=> end
}

public func writeHeader<A>(_ header: Response.Header) -> Middleware<HeadersOpen, HeadersOpen, A, A> {
  return { conn in
    var conn = conn
    conn.response.head.headers.add(name: header.name, value: header.value)
    return conn.channel.eventLoop.makeSucceededFuture(conn)
  }
}

public func redirect<A>(
  to location: String,
  status: HTTPResponseStatus = .found,
  headersMiddleware: @escaping Middleware<HeadersOpen, HeadersOpen, A, A> =
  { $0.channel.eventLoop.makeSucceededFuture($0) }
  )
  ->
  Middleware<StatusLineOpen, ResponseEnded, A, Void> {

    return writeStatus(status)
      >=> headersMiddleware
      >=> writeHeader(.location(location))
      >=> end
}

public func closeHeaders<A>(_ conn: Conn<HeadersOpen, A>) -> EventLoopFuture<Conn<BodyOpen, A>> {
  let conn = conn.transition(to: BodyOpen.self)
  _ = conn.channel.writeAndFlush(HTTPServerResponsePart.head(conn.response.head))
  return conn.channel.eventLoop.makeSucceededFuture(conn)
}

public func writeBody<A>(_ bytes: [UInt8]) -> Middleware<BodyOpen, BodyOpen, A, A> {
  return { conn in
    var buffer = conn.channel.allocator.buffer(capacity: bytes.count)
    buffer.write(bytes: bytes)
    _ = conn.channel.writeAndFlush(HTTPServerResponsePart.body(.byteBuffer(buffer)))
    return conn.channel.eventLoop.makeSucceededFuture(conn)
  }
}

public func end<A>(_ conn: Conn<BodyOpen, A>) -> EventLoopFuture<Conn<ResponseEnded, Void>> {
  let conn = conn.transition(to: ResponseEnded.self).map(const(()))
  return conn.channel.writeAndFlush(HTTPServerResponsePart.end(nil))
    .flatMap {
      conn.request.head.isKeepAlive
        ? conn.channel.eventLoop.makeSucceededFuture(())
        : conn.channel.close()
    }
    .map(const(conn))
}

public func end<A>(_ conn: Conn<HeadersOpen, A>) -> EventLoopFuture<Conn<ResponseEnded, Void>> {
  return conn |> closeHeaders >=> end
}

public func respond<A>(text: String) -> Middleware<HeadersOpen, ResponseEnded, A, Void> {
  return respond(body: text, contentType: .plain)
}

public func respond<A>(html: String) -> Middleware<HeadersOpen, ResponseEnded, A, Void> {
  return respond(body: html, contentType: .html)
}

public func respond<A>(json: String) -> Middleware<HeadersOpen, ResponseEnded, A, Void> {
  return respond(body: json, contentType: .json)
}

public func respond<A>(body: String, contentType: MediaType)
  -> Middleware<HeadersOpen, ResponseEnded, A, Void> {

    let data = [UInt8](body.utf8)

    return writeHeader(.contentType(contentType))
      >=> writeHeader(.contentLength(data.count))
      >=> closeHeaders
      >=> writeBody(data)
      >=> end
}

extension Conn {
  internal func transition<NextStep>(to step: NextStep.Type) -> Conn<NextStep, Value> {
    return Conn<NextStep, Value>(
      channel: self.channel,
      request: self.request,
      response: self.response,
      value: self.value
    )
  }
}
