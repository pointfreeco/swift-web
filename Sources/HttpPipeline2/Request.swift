import Foundation
import NIO
import NIOHTTP1
import Prelude

public struct Request {
  public var head: HTTPRequestHead
  public var body: [UInt8]?
}

extension Request {
  public var host: String? {
    return self.head.headers["Host"].first
  }

  public var scheme: String {
    return self.head.headers["X-Forwarded-Proto"].first ?? "http"
  }

  public var url: String? {
    return self.host.map { self.scheme + "://" + $0 + self.head.uri }
  }
}
