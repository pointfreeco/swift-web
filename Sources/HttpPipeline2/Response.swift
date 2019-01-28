import Html
import NIO
import NIOHTTP1

public struct Response {
  public var head: HTTPResponseHead

  public struct Header {
    public var name: String
    public var value: String
  }
}

extension Response {
  init(request: Request) {
    var head = HTTPResponseHead(version: request.head.version, status: .internalServerError)
    switch (request.head.isKeepAlive, request.head.version.major, request.head.version.minor) {
    case (true, 1, 0):
      head.headers.add(name: "Connection", value: "keep-alive")
    case (false, 1, 1):
      head.headers.add(name: "Connection", value: "close")
    default:
      ()
    }
    self.head = head
  }
}

extension Response.Header {
  public static func allow(_ methods: [HTTPMethod]) -> Response.Header {
    return Response.Header(name: "Allow", value: methods.map(methodName).joined(separator: ", "))
  }

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

private func methodName(_ method: HTTPMethod) -> String {
  switch method {
  case .ACL: return "ACL"
  case .BIND: return "BIND"
  case .CHECKOUT: return "CHECKOUT"
  case .CONNECT: return "CONNECT"
  case .COPY: return "COPY"
  case .DELETE: return "DELETE"
  case .GET: return "GET"
  case .HEAD: return "HEAD"
  case .LINK: return "LINK"
  case .LOCK: return "LOCK"
  case .MERGE: return "MERGE"
  case .MKACTIVITY: return "MKACTIVITY"
  case .MKCALENDAR: return "MKCALENDAR"
  case .MKCOL: return "MKCOL"
  case .MOVE: return "MOVE"
  case .MSEARCH: return "MSEARCH"
  case .NOTIFY: return "NOTIFY"
  case .OPTIONS: return "OPTIONS"
  case .PATCH: return "PATCH"
  case .POST: return "POST"
  case .PROPFIND: return "PROPFIND"
  case .PROPPATCH: return "PROPPATCH"
  case .PURGE: return "PURGE"
  case .PUT: return "PUT"
  case .REBIND: return "REBIND"
  case .REPORT: return "REPORT"
  case .SEARCH: return "SEARCH"
  case .SUBSCRIBE: return "SUBSCRIBE"
  case .TRACE: return "TRACE"
  case .UNBIND: return "UNBIND"
  case .UNLINK: return "UNLINK"
  case .UNLOCK: return "UNLOCK"
  case .UNSUBSCRIBE: return "UNSUBSCRIBE"
  case let .RAW(value): return value
  }
}
