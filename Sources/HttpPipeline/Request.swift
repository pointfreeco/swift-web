import Foundation
import HTTPTypes
import NIOCore

public struct Request {
  public var head: HTTPRequest
  public var body: ByteBuffer

  public var url: URL? { head.url }
  public var method: HTTPRequest.Method { head.method }
  public var headers: HTTPFields { head.headerFields }

  public init(head: HTTPRequest, body: ByteBuffer = .init()) {
    self.head = head
    self.body = body
  }

  public init(url: URL) {
    self.init(head: .init(url: url), body: .init())
  }

  public func toURLRequest() -> URLRequest? {
    var urlRequest = URLRequest(httpRequest: head)
    var body = self.body
    urlRequest?.httpBody = body.readBytes(length: body.readableBytes).map({ Data($0) })
    return urlRequest
  }
}
