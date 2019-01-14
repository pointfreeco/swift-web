import Foundation
import Html
import Optics
import Prelude

public struct Response {
  public var status: Status
  public var headers: [Header]
  public var body: Data

  public struct Header {
    public let name: String
    public let value: String

    public init(_ name: String, _ value: String) {
      self.name = name
      self.value = value
    }

    public static func allow(_ methods: [Method]) -> Header {
      return .init("Allow", methods.map(^\.description).joined(separator: ", "))
    }

    public static func contentLength(_ length: Int) -> Header {
      return .init("Content-Length", String(length))
    }

    public static func contentType(_ type: MediaType) -> Header {
      return .init("Content-Type", type.description)
    }

    public static func location(_ location: String) -> Header {
      return .init("Location", location)
    }

    public static func setCookie(_ name: String, _ value: String, _ options: Set<CookieOption> = [])
      -> Header {

        let stringValue = ([name + "=" + value] + options.map(^\.description).sorted())
          .joined(separator: "; ")

        return .init("Set-Cookie", stringValue)
    }

    public static func wwwAuthenticate(_ authenticate: Authenticate) -> Header {
      switch authenticate {
      case let .basic(realm):
        let realmString = realm.map { " realm=\"" + $0 + "\"" } ?? ""
        return .init("WWW-Authenticate", "Basic" + realmString)
      }
    }

    public enum Authenticate {
      case basic(realm: String?)
    }

    public enum CookieOption: Hashable, CustomStringConvertible, Comparable {
      case domain(String)
      case expires(Date)
      case httpOnly
      case maxAge(Int)
      case path(String)
      case sameSite(SameSite)
      case secure

      public static func <(lhs: CookieOption, rhs: CookieOption) -> Bool {
        return lhs.description < rhs.description
      }

      public var description: String {
        switch self {
        case let .domain(domain):
          return "Domain=" + domain
        case let .expires(date):
          return "Expires=" + expiresDateFormatter.string(from: date)
        case .httpOnly:
          return "HttpOnly"
        case let .maxAge(maxAge):
          return "Max-Age=" + String(maxAge)
        case let .path(path):
          return "Path=" + path
        case let .sameSite(sameSite):
          return "SameSite=" + sameSite.rawValue
        case .secure:
          return "Secure"
        }
      }

      public func hash(into hasher: inout Hasher) {
        switch self {
        case let .domain(domain):     return hasher.combine(domain)
        case let .expires(time):      return hasher.combine(time)
        case .httpOnly:               return hasher.combine("httpOnly")
        case let .maxAge(maxAge):     return hasher.combine(maxAge)
        case let .path(path):         return hasher.combine(path)
        case let .sameSite(sameSite): return hasher.combine(sameSite)
        case .secure:                 return hasher.combine("secure")
        }
      }

      public static func ==(lhs: CookieOption, rhs: CookieOption) -> Bool {
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

      public enum SameSite: String {
        case lax = "Lax"
        case strict = "Strict"
      }
    }

    public static func setCookies(_ pairs: [(key: String, value: String)], options: Set<CookieOption>)
      -> [Header] {

        return pairs.map { .setCookie($0.key, $0.value, options) }
    }

    public static func clearCookie(_ name: String) -> Header {
      return .setCookie(name, "", [.maxAge(0), .expires(Date(timeIntervalSince1970: 0))])
    }

    public var description: String {
      return self.name + ": " + self.value
    }
  }
}

private let expiresDateFormatter = DateFormatter()
  |> \.dateFormat .~ "EEE, d MMM yyyy HH:mm:ss zzz"
  |> \.locale .~ Locale(identifier: "en_US_POSIX")
  |> \.timeZone .~ TimeZone(abbreviation: "GMT")
