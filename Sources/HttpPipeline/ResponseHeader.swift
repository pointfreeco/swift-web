import Foundation
import MediaType
import Prelude

public enum ResponseHeader {
  case allow([Method])
  case contentLength(Int)
  case contentType(MediaType)
  case location(String)
  case setCookie(key: String, value: String, options: Set<CookieOption>)
  case other(String, String)
  case wwwAuthenticate(Authenticate)

  public enum CookieOption: Hashable, CustomStringConvertible {
    case domain(String)
    case expires(TimeInterval)
    case httpOnly
    case maxAge(Int)
    case path(String)
    case sameSite(SameSite)
    case secure

    public var description: String {
      switch self {
      case let .domain(domain):
        return "Domain=\(domain)"
      case let .expires(time):
        return "Expires=" + expiresDateFormatter.string(from: .init(timeIntervalSince1970: time))
      case .httpOnly:
        return "HttpOnly"
      case let .maxAge(maxAge):
        return "Max-Age=\(maxAge)"
      case let .path(path):
        return "Path=\(path)"
      case let .sameSite(sameSite):
        return "SameSite=\(sameSite.description)"
      case .secure:
        return "Secure"
      }
    }

    public var hashValue: Int {
      switch self {
      case let .domain(domain):     return domain.hashValue
      case let .expires(time):      return time.hashValue
      case .httpOnly:               return 1
      case let .maxAge(maxAge):     return maxAge.hashValue
      case let .path(path):         return path.hashValue
      case let .sameSite(sameSite): return sameSite.hashValue
      case .secure:                 return 2
      }
    }

    public static func ==(lhs: ResponseHeader.CookieOption, rhs: ResponseHeader.CookieOption) -> Bool {
      switch (lhs, rhs) {
      case let (.domain(lhs), .domain(rhs)):
        return lhs == rhs
      case let (.expires(lhs), .expires(rhs)):
        return lhs == rhs
      case (.httpOnly, .httpOnly):
        return true
      case let (.maxAge(lhs), .maxAge(rhs)):
        return lhs == rhs
      case let (.path(lhs), .path(rhs)):
        return lhs == rhs
      case let (.sameSite(lhs), .sameSite(rhs)):
        return lhs == rhs
      case (.secure, .secure):
        return true
      case (.domain, _), (.expires, _), (.httpOnly, _), (.maxAge, _), (.path, _), (.sameSite, _),
           (.secure, _):
        return false
      }
    }

    public enum SameSite: Hashable, CustomStringConvertible {
      case lax
      case strict 

      public var description: String {
        switch self {
        case .lax:    return "Lax"
        case .strict: return "String"
        }
      }
    }
  }

  public static func setCookies(_ pairs: [String: String], options: Set<CookieOption>) -> [ResponseHeader] {
    return pairs.map { .setCookie(key: $0.key, value: $0.value, options: options) }
  }

  public static func clearCookie(key: String) -> ResponseHeader {
    return .setCookie(key: key, value: "", options: [CookieOption.maxAge(0), .expires(0)])
  }

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
    case let .setCookie(key: key, value: value, options: options):
      // TODO: escape
      let headerValue = (["\(key)=\(value)"] + options.map(get(\.description))).joined(separator: "; ")
      return ("Set-Cookie", headerValue)
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

private let expiresDateFormatter: DateFormatter = { () -> DateFormatter in
  let formatter = DateFormatter()
  formatter.timeZone = TimeZone(abbreviation: "UTC")
  formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
  formatter.string(from: Date())
  return formatter
}()
