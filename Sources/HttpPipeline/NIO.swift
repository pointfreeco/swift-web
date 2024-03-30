import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import NIO
import NIOHTTP1
import NIOHTTPCompression
import Optics
import Prelude

public func run(
  _ middleware: @escaping (Conn<StatusLineOpen, Prelude.Unit>) async -> Conn<ResponseEnded, Data>,
  on port: Int = 8080,
  eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount),
  gzip: Bool = false,
  baseUrl: URL
  ) {

  do {
    let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
    let bootstrap = ServerBootstrap(group: eventLoopGroup)
      .serverChannelOption(ChannelOptions.backlog, value: 256)
      .serverChannelOption(reuseAddrOpt, value: 1)
      .childChannelInitializer { channel in
        channel.pipeline.configureHTTPServerPipeline().flatMap {
          let handlers: [ChannelHandler] = gzip
            ? [HTTPResponseCompressor(), Handler(baseUrl: baseUrl, middleware: middleware)]
            : [Handler(baseUrl: baseUrl, middleware: middleware)]
          return channel.pipeline.addHandlers(handlers, position: .last)
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
  typealias InboundIn = HTTPServerRequestPart

  let baseUrl: URL
  var request: URLRequest?
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
    case let .head(header):
      self.request = URL(string: header.uri).map {
        var req = URLRequest(url: $0)
        req.httpMethod = method(from: header.method)
        req.allHTTPHeaderFields = header.headers.reduce(into: [:]) { $0[$1.name] = $1.value }
        let proto = req.value(forHTTPHeaderField: "X-Forwarded-Proto") ?? "http"
        req.url = req.value(forHTTPHeaderField: "Host").flatMap {
          URL(string: proto + "://" + $0 + header.uri)
        }
        return req
      }
    case var .body(bodyPart):
      self.request = self.request |> map <<< \.httpBody %~ {
        var data = $0 ?? .init()
        bodyPart.readBytes(length: bodyPart.readableBytes).do { data.append(Data($0)) }
        return data
      }
    case .end:
      guard let req = self.request else {
        context.channel.write(
          HTTPServerResponsePart.head(
            HTTPResponseHead(
              version: .init(major: 1, minor: 1),
              status: .init(statusCode: 307),
              headers: .init([("location", self.baseUrl.absoluteString)])
            )
          ),
          promise: nil
        )
        _ = context.channel.writeAndFlush(HTTPServerResponsePart.end(nil)).flatMap {
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
