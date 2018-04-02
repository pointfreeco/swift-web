import Foundation
import NIO
import NIOHTTP1
import Optics
import Prelude

public func run(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>,
  on port: Int = 8080
  ) {

  do {
    let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
    let group = MultiThreadedEventLoopGroup(numThreads: System.coreCount)
    let bootstrap = ServerBootstrap(group: group)
      .serverChannelOption(ChannelOptions.backlog, value: 256)
      .serverChannelOption(reuseAddrOpt, value: 1)
      .childChannelInitializer { channel in
        channel.pipeline.configureHTTPServerPipeline().then {
          channel.pipeline.add(handler: Handler(middleware))
        }
      }
      .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
      .childChannelOption(reuseAddrOpt, value: 1)
      .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

    let serverChannel = try bootstrap.bind(host: "localhost", port: port).wait()
    try serverChannel.closeFuture.wait()
    try group.syncShutdownGracefully()
  } catch {
    fatalError(error.localizedDescription)
  }
}

private final class Handler: ChannelInboundHandler {
  typealias InboundIn = HTTPServerRequestPart

  var request: URLRequest?
  let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>

  init(_ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>) {
    self.middleware = middleware
  }

  func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
    let reqPart = self.unwrapInboundIn(data)

    switch reqPart {
    case let .head(header):
      self.request = URL(string: header.uri).map {
        URLRequest(url: $0)
          |> \.httpMethod .~ method(from: header.method)
          |> \.allHTTPHeaderFields .~ header.headers.reduce(into: [:]) { $0[$1.name] = $1.value }
      }
    case let .body(bodyPart):
      self.request = self.request.flatMap { req -> URLRequest? in
        req.value(forHTTPHeaderField: "Content-Length")
          .flatMap(Int.init)
          .flatMap { bodyPart.getBytes(at: 0, length: $0) }
          .map { req |> \.httpBody .~ Data($0) }
      }
    case .end:
      guard let req = self.request else {
        _ = ctx.channel.close()
        return
      }

      let conn = self.middleware(connection(from: req)).perform()
      let res = conn.response

      let head = HTTPResponseHead(
        version: .init(major: 1, minor: 1),
        status: .init(statusCode: res.status.rawValue),
        headers: .init(res.headers.map { ($0.name, $0.value) })
      )
      _ = ctx.channel.write(HTTPServerResponsePart.head(head))

      var buffer = ctx.channel.allocator.buffer(capacity: res.body.count)
      buffer.write(bytes: res.body)
      _ = ctx.channel.write(HTTPServerResponsePart.body(.byteBuffer(buffer)))

      _ = ctx.channel.writeAndFlush(HTTPServerResponsePart.end(nil)).then {
        ctx.channel.close()
      }
    }
  }
}

private func method(from method: HTTPMethod) -> String {
  switch method {
  case .GET: return "GET"
  case .PUT: return "PUT"
  case .ACL: return "ACL"
  case .HEAD: return "HEAD"
  case .POST: return "POST"
  case .COPY: return "COPY"
  case .LOCK: return "LOCK"
  case .MOVE: return "MOVE"
  case .BIND: return "BIND"
  case .LINK: return "LINK"
  case .PATCH: return "PATCH"
  case .TRACE: return "TRACE"
  case .MKCOL: return "MKCOL"
  case .MERGE: return "MERGE"
  case .PURGE: return "PURGE"
  case .NOTIFY: return "NOTIFY"
  case .SEARCH: return "SEARCH"
  case .UNLOCK: return "UNLOCK"
  case .REBIND: return "REBIND"
  case .UNBIND: return "UNBIND"
  case .REPORT: return "REPORT"
  case .DELETE: return "DELETE"
  case .UNLINK: return "UNLINK"
  case .CONNECT: return "CONNECT"
  case .MSEARCH: return "MSEARCH"
  case .OPTIONS: return "OPTIONS"
  case .PROPFIND: return "PROPFIND"
  case .CHECKOUT: return "CHECKOUT"
  case .PROPPATCH: return "PROPPATCH"
  case .SUBSCRIBE: return "SUBSCRIBE"
  case .MKCALENDAR: return "MKCALENDAR"
  case .MKACTIVITY: return "MKACTIVITY"
  case .UNSUBSCRIBE: return "UNSUBSCRIBE"
  case let .RAW(value): return value
  }
}

private func headers(from headers: HTTPHeaders) -> [String: String] {
  return headers.reduce(into: [:]) { headers, pair in
    headers[pair.name] = pair.value
  }
}
