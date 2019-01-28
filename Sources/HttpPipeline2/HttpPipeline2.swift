import Foundation
import Html
import NIO
import NIOHTTP1
import Prelude

public func >=> <A, B, C>(f: @escaping (A) -> EventLoopFuture<B>, g: @escaping (B) -> EventLoopFuture<C>)
  -> (A) -> EventLoopFuture<C> {

    return { f($0).flatMap(g) }
}

public enum StatusLineOpen {}
public enum HeadersOpen {}
public enum BodyOpen {}
public enum ResponseEnded {}

public struct Request {
  public var head: HTTPRequestHead
  public var body: Data
}

public struct Response {
  public var head: HTTPResponseHead
  public var body: Data

  public struct Header {
    public var name: String
    public var value: String
  }
}

extension Response.Header {
  public static func contentLength(_ length: Int) -> Response.Header {
    return Response.Header(name: "Content-Length", value: String(length))
  }

  public static func contentType(_ type: MediaType) -> Response.Header {
    return Response.Header(name: "Content-Type", value: type.description)
  }

  public static func location(_ location: String) -> Response.Header {
    return Response.Header(name: "Location", value: location)
  }
}

public struct Conn<Step, Value> {
  public var eventLoop: EventLoop
  public var request: Request
  public var response: Response
  public var value: Value
}

public typealias Middleware<I, J, A, B> = (Conn<I, A>) -> EventLoopFuture<Conn<J, B>>
public typealias AppMiddleware = Middleware<StatusLineOpen, ResponseEnded, Void, Void>

extension Conn {
  public func map<NewValue>(_ transform: (Value) -> NewValue) -> Conn<Step, NewValue> {
    return Conn<Step, NewValue>(
      eventLoop: self.eventLoop,
      request: self.request,
      response: self.response,
      value: transform(self.value)
    )
  }

  internal func transition<NextStep>(to step: NextStep.Type) -> Conn<NextStep, Value> {
    return Conn<NextStep, Value>(
      eventLoop: self.eventLoop,
      request: self.request,
      response: self.response,
      value: self.value
    )
  }
}

public func writeStatus<A>(_ status: HTTPResponseStatus) -> Middleware<StatusLineOpen, HeadersOpen, A, A> {
  return { conn in
    var conn = conn.transition(to: HeadersOpen.self)
    conn.response.head.status = status
    return conn.eventLoop.makeSucceededFuture(conn)
  }
}

public func head<A>(_ status: HTTPResponseStatus) -> Middleware<StatusLineOpen, ResponseEnded, A, Void> {
  return writeStatus(status) >=> end
}

public func writeHeader<A>(_ header: Response.Header) -> Middleware<HeadersOpen, HeadersOpen, A, A> {
  return { conn in
    var conn = conn
    conn.response.head.headers.add(name: header.name, value: header.value)
    return conn.eventLoop.makeSucceededFuture(conn)
  }
}

public func redirect<A>(
  to location: String,
  status: HTTPResponseStatus = .found,
  headersMiddleware: @escaping Middleware<HeadersOpen, HeadersOpen, A, A> =
  { $0.eventLoop.makeSucceededFuture($0) }
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
  return conn.eventLoop.makeSucceededFuture(conn)
}

public func writeBody<A>(_ data: Data) -> Middleware<BodyOpen, BodyOpen, A, A> {
  return { conn in
    var conn = conn
    conn.response.body.append(data)
    return conn.eventLoop.makeSucceededFuture(conn)
  }
}

public func end<A>(_ conn: Conn<BodyOpen, A>) -> EventLoopFuture<Conn<ResponseEnded, Void>> {
  let conn = conn.map(const(())).transition(to: ResponseEnded.self)
  return conn.eventLoop.makeSucceededFuture(conn)
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

    let data = Data(body.utf8)

    return writeHeader(.contentType(contentType))
      >=> writeHeader(.contentLength(data.count))
      >=> closeHeaders
      >=> writeBody(data)
      >=> end
}
