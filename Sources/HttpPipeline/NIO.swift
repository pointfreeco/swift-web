import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes
import HTTPTypesFoundation
import NIO
import NIOHTTPTypes
import NIOHTTPTypesHTTP1
import NIOHTTP1
import Optics
import Prelude

public func run(
  _ middleware: @escaping (Conn<StatusLineOpen, Prelude.Unit>) async -> Conn<ResponseEnded, Data>,
  on port: Int = 8080,
  eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount),
  baseUrl: URL
  ) {
  let secure = baseUrl.scheme == "https"
  do {
    let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
    let bootstrap = ServerBootstrap(group: eventLoopGroup)
      .serverChannelOption(ChannelOptions.backlog, value: 256)
      .serverChannelOption(reuseAddrOpt, value: 1)
      .childChannelInitializer { channel in
        channel.pipeline.configureHTTPServerPipeline().flatMap {
          channel.pipeline.addHandlers([
            HTTP1ToHTTPServerCodec(secure: secure),
            Handler(baseUrl: baseUrl, middleware: middleware),
          ], position: .last)
        }
      }
      .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
      .childChannelOption(reuseAddrOpt, value: 1)
      .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

    let host = "0.0.0.0"
    let serverChannel = try bootstrap.bind(host: host, port: port).wait()
    print("Listening on \(host):\(port)...")
    try serverChannel.closeFuture.wait()
    try eventLoopGroup.syncShutdownGracefully()
  } catch {
    fatalError(error.localizedDescription)
  }
}

private final class Handler: ChannelInboundHandler {
  typealias InboundIn = HTTP1ToHTTPServerCodec.InboundOut
  typealias OutboundOut = HTTP1ToHTTPServerCodec.OutboundIn

  let baseUrl: URL
  var request: Request?
  let middleware: (Conn<StatusLineOpen, Prelude.Unit>) async -> Conn<ResponseEnded, Data>

  init(
    baseUrl: URL,
    middleware: @escaping (Conn<StatusLineOpen, Prelude.Unit>) async -> Conn<ResponseEnded, Data>
  ) {
    self.baseUrl = baseUrl
    self.middleware = middleware
  }

  func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let reqPart = self.unwrapInboundIn(data)

    switch reqPart {
    case let .head(head):
      self.request = .init(head: head, body: .init())
    case var .body(body):
      self.request?.body.writeBuffer(&body)
    case .end:
      guard let req = self.request else {
        context.write(wrapOutboundOut(.head(.init(status: .internalServerError))), promise: nil)
        _ = context.writeAndFlush(wrapOutboundOut(.end(nil))).flatMap {
          context.close()
        }
        return
      }

      let promise = context.eventLoop.makePromise(of: Conn<ResponseEnded, Data>.self)
      promise.completeWithTask {
        await self.middleware(connection(from: req))
      }
      _ = promise.futureResult.flatMap { conn -> EventLoopFuture<Void> in
        let res = conn.response

        let head = HTTPResponse(status: res.status, headerFields: res.headers)
        context.write(self.wrapOutboundOut(.head(head)), promise: nil)

        var buffer = context.channel.allocator.buffer(capacity: res.body.count)
        buffer.writeBytes(res.body)
        context.write(self.wrapOutboundOut(.body(buffer)), promise: nil)

        return context.writeAndFlush(self.wrapOutboundOut(.end(nil))).flatMap {
          context.close()
        }
      }
    }
  }

  func errorCaught(context: ChannelHandlerContext, error: Error) {
    context.close(promise: nil)
  }
}

private func method(from method: HTTPMethod) -> String {
  return method.rawValue
}
