import MediaType

public enum ResponseHeader {
  case allow([Method])
  case contentLength(Int)
  case contentType(MediaType)
  case location(String)
  case setCookie([String: String])
  case other(String, String)
  case wwwAuthenticate(Authenticate)

  public enum Authenticate {
    case basic(realm: String?)
  }

  public var pair: (String, String) {
    switch self {
    case let .allow(methods):
      return ("Allow", methods.map { $0.description }.joined(separator: ", "))
    case let .contentLength(bytes):
      return ("Content-Length", bytes.description)
    case let .contentType(mediaType):
      return ("Content-Type", mediaType.description)
    case let .location(uri):
      return ("Location", uri)
    case let .setCookie(cookies):
      let str = cookies.map { (pair: (key: String, value: String)) in
        pair.key + "=" + pair.value // TODO: escape
      }.joined(separator: "; ")
      return ("Set-Cookie", str)
    case let .other(header, value):
      return (header, value)
    case let .wwwAuthenticate(authenticate):
      switch authenticate {
      case let .basic(realm: realm):
        return ("WWW-Authenticate", "Basic" + (realm.map { " realm=\"\($0)\"" } ?? ""))
      }
    }
  }

  public var description: String {
    let (key, value) = self.pair
    return key + ": " + value
  }
}
