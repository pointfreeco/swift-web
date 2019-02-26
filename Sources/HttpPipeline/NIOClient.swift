import Foundation
import NIO
import NIOHTTP1

struct HTTPError: Error {}

public struct Request {
  var method: HTTPMethod
  var url: String
  var headers: [String: String]
  var body: [UInt8]?

  public static func get(_ url: String, headers: [String: String] = [:]) -> Request {
    return Request(method: .GET, url: url, headers: headers, body: nil)
  }

  public static func post(_ url: String, headers: [String: String] = [:], body: [UInt8]) -> Request {
    return Request(method: .POST, url: url, headers: headers, body: body)
  }
}

public func request(
  to request: Request,
  connectTimeout: TimeAmount = .seconds(60),
  group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
  )
  -> EventLoopFuture<(HTTPResponseHead, [UInt8])> {

    class Handler: ChannelInboundHandler {
      typealias Response = (HTTPResponseHead, [UInt8])
      typealias InboundIn = HTTPClientResponsePart

      var body: [UInt8] = []
      var head: HTTPResponseHead?
      let promise: EventLoopPromise<Response>

      init(group: EventLoopGroup) {
        self.promise = group.next().newPromise(of: Response.self)
      }

      func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        switch self.unwrapInboundIn(data) {
        case let .head(head):
          self.head = head
        case var .body(body):
          if let bytes = body.readBytes(length: body.readableBytes) {
            self.body.append(contentsOf: bytes)
          }
        case .end:
          if let head = self.head {
            self.promise.succeed(result: (head, self.body))
          } else {
            self.promise.fail(error: HTTPError())
          }
        }
      }

      func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        self.promise.fail(error: error)
      }
    }

    guard
      let urlComponents = URLComponents(string: request.url),
      let host = urlComponents.host
      else { return group.next().newFailedFuture(error: HTTPError()) }

    let handler = Handler(group: group)

    return ClientBootstrap(group: group)
      .connectTimeout(connectTimeout)
      .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
      .channelInitializer { channel in
        channel.pipeline.addHTTPClientHandlers().then {
          channel.pipeline.add(handler: handler)
        }
      }
      .connect(host: host, port: urlComponents.port ?? 80)
      .then { channel -> EventLoopFuture<Void> in
        var head = HTTPRequestHead(
          version: HTTPVersion(major: 1, minor: 1),
          method: request.method,
          uri: urlComponents.path.isEmpty ? "/" : urlComponents.path
        )
        head.headers.add(name: "Host", value: host)
        request.headers.forEach { head.headers.add(name: $0, value: $1) }
        channel.write(NIOAny(HTTPClientRequestPart.head(head)), promise: nil)
        if let body = request.body {
          var buffer = channel.allocator.buffer(capacity: body.count)
          buffer.write(bytes: body)
          channel.write(NIOAny(HTTPClientRequestPart.body(.byteBuffer(buffer))), promise: nil)
        }
        return channel.writeAndFlush(NIOAny(HTTPClientRequestPart.end(nil)))
      }
      .then { handler.promise.futureResult }
}
