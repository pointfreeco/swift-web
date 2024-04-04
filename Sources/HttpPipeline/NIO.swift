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
  baseUrl: URL,
  defaultHeaders: HTTPFields = [:]
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
            Handler(baseUrl: baseUrl, middleware: middleware, defaultHeaders: defaultHeaders),
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
  var request: URLRequest?
  let middleware: (Conn<StatusLineOpen, Prelude.Unit>) async -> Conn<ResponseEnded, Data>
  let defaultHeaders: HTTPFields

  init(
    baseUrl: URL,
    middleware: @escaping (Conn<StatusLineOpen, Prelude.Unit>) async -> Conn<ResponseEnded, Data>,
    defaultHeaders: HTTPFields
  ) {
    self.baseUrl = baseUrl
    self.middleware = middleware
    self.defaultHeaders = defaultHeaders
  }

  func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let reqPart = self.unwrapInboundIn(data)

    switch reqPart {
    case let .head(header):
      self.request = URLRequest(httpRequest: header)
    case var .body(bodyPart):
      self.request = self.request |> map <<< \.httpBody %~ {
        var data = $0 ?? .init()
        bodyPart.readBytes(length: bodyPart.readableBytes).do { data.append(Data($0)) }
        return data
      }
    case .end:
      guard let req = self.request else {
        context.write(wrapOutboundOut(.head(.init(status: .internalServerError))), promise: nil)
        _ = context.writeAndFlush(wrapOutboundOut(.end(nil))).flatMap {
          context.channel.close()
        }
        return
      }

      let promise = context.eventLoop.makePromise(of: Conn<ResponseEnded, Data>.self)
      promise.completeWithTask {
        await self.middleware(connection(from: req))
      }
      _ = promise.futureResult.flatMap { conn -> EventLoopFuture<Void> in
        let res = conn.response

        let head = HTTPResponseHead(
          version: .init(major: 1, minor: 1),
          status: .init(statusCode: res.status.code),
          headers: .init(res.headers.map { ($0.name.rawName, $0.value) })
        )
        context.channel.write(HTTPServerResponsePart.head(head), promise: nil)

        var buffer = context.channel.allocator.buffer(capacity: res.body.count)
        buffer.writeBytes(res.body)
        context.channel.write(HTTPServerResponsePart.body(.byteBuffer(buffer)), promise: nil)

        return context.channel.writeAndFlush(HTTPServerResponsePart.end(nil)).flatMap {
          context.channel.close()
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
