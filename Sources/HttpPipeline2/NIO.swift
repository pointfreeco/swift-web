import Foundation
import NIO
import NIOHTTP1

public func run(
  _ middleware: @escaping AppMiddleware,
  on port: Int = 8080,
  baseUrl: URL = URL(string: "http://0.0.0.0")!,
  eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount),
  gzip: Bool = false
  ) {

  do {
    let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    let bootstrap = ServerBootstrap(group: group)
      .serverChannelOption(ChannelOptions.backlog, value: 256)
      .serverChannelOption(reuseAddrOpt, value: 1)
      .childChannelInitializer { channel in
        channel.pipeline.configureHTTPServerPipeline().flatMap {
          let handlers: [ChannelHandler] = gzip
            ? [HTTPResponseCompressor(), Handler(baseUrl: baseUrl, middleware: middleware)]
            : [Handler(baseUrl: baseUrl, middleware: middleware)]
          return channel.pipeline.addHandlers(handlers, first: false)
        }
      }
      .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
      .childChannelOption(reuseAddrOpt, value: 1)
      .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
//      .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: true)

    let host = "0.0.0.0"
    let serverChannel = try bootstrap.bind(host: host, port: port).wait()
    print("Listening on \(host):\(port)...")
    try serverChannel.closeFuture.wait()
    try group.syncShutdownGracefully()
  } catch {
    fatalError(error.localizedDescription)
  }
}

private final class Handler: ChannelInboundHandler {
  typealias InboundIn = HTTPServerRequestPart

  let baseUrl: URL
  var head: HTTPRequestHead?
  var body = Data()
  let middleware: AppMiddleware

  init(baseUrl: URL, middleware: @escaping AppMiddleware) {
    self.baseUrl = baseUrl
    self.middleware = middleware
  }

  func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
    let reqPart = self.unwrapInboundIn(data)

    switch reqPart {
    case let .head(header):
      self.head = header
    case var .body(bodyPart):
      if let bodyPart = bodyPart.readBytes(length: bodyPart.readableBytes) {
        self.body.append(contentsOf: bodyPart)
      }
    case .end:
      guard let head = self.head else {
        let badRequest = HTTPResponseHead(
          version: HTTPVersion(major: 1, minor: 1),
          status: .badRequest,
          headers: HTTPHeaders()
        )
        _ = ctx.channel.write(HTTPServerResponsePart.head(badRequest))
        _ = ctx.channel.writeAndFlush(HTTPServerResponsePart.end(nil))
          .flatMap { ctx.channel.close() }
        return
      }

      let conn = Conn<StatusLineOpen, Void>(
        eventLoop: ctx.eventLoop,
        request: Request(head: head, body: self.body),
        response: Response(
          head: HTTPResponseHead(
            version: head.version,
            status: .internalServerError
          ),
          body: Data()
        ),
        value: ()
      )

      _ = self.middleware(conn).flatMap { conn -> EventLoopFuture<Void> in
        _ = ctx.channel.write(HTTPServerResponsePart.head(conn.response.head))

        var buffer = ctx.channel.allocator.buffer(capacity: conn.response.body.count)
        buffer.write(bytes: conn.response.body)
        _ = ctx.channel.write(HTTPServerResponsePart.body(.byteBuffer(buffer)))

        let p: EventLoopPromise<Void> = conn.eventLoop.makePromise()
        DispatchQueue.global(qos: .background)
          .asyncAfter(deadline: .now() + 1, execute: {
            p.succeed(())
          })

        return p.futureResult.flatMap {
          var buffer = ctx.channel.allocator.buffer(capacity: conn.response.body.count)
          buffer.write(bytes: conn.response.body)
          _ = ctx.channel.write(HTTPServerResponsePart.body(.byteBuffer(buffer)))

          return ctx.channel.writeAndFlush(HTTPServerResponsePart.end(nil))
            .flatMap { ctx.channel.close() }
        }
      }
    }
  }
}
