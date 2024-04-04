import Foundation
import Html
import HttpPipeline
import Prelude
import Optics
import View

func echoBody<S, A>(_ conn: Conn<S, A>) -> Conn<S, Data> {
  var body = conn.request.body
  let data = body.readBytes(length: body.readableBytes).map({ Data($0) }) ?? .init()
  return conn.map(const(data))
}

let loggerMiddleware = requestLogger(logger: { print($0) }, uuid: { .init() })

let echoMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
    writeStatus(.ok)
    >=> writeHeader(.contentType(.text(.plain, charset: .utf8)))
    >=> closeHeaders
    >>> map(echoBody)
    >=> end

func ioToAsync<I, A, J, B>(_ ioMiddleware: @escaping Middleware<I, J, A, B>) -> (Conn<I, A>) async -> Conn<J, B> {
  { conn in
    await ioMiddleware(conn).performAsync()
  }
}

let middleware = ioToAsync
  <| loggerMiddleware
  <| echoMiddleware

run(middleware, on: 4567, baseUrl: .init(string: "http://localhost:4567")!)
