import Foundation
import Html
import HTTPTypes
import Optics
import Prelude

extension HTTPField.Name {
  public static var referrerPolicy: Self = .init("Referrer-Policy")!
  public static var xDownloadOptions: Self = .init("X-Download-Options")!
  public static var xFrameOptions: Self = .init("X-Frame-Options")!
  public static var xPermittedCrossDomainPolicies: Self = .init("X-Permitted-Cross-Domain-Policies")!
  public static var xXssProtection: Self = .init("X-XSS-Protection")!
}

extension HTTPField {
  public static func allow(_ methods: [Method]) -> Self {
    return .init(name: .allow, value: methods.map(^\.description).joined(separator: ", "))
  }

  public static func contentLength(_ length: Int) -> Self {
    return .init(name: .contentLength, value: String(length))
  }

  public static func contentType(_ type: MediaType) -> Self {
    return .init(name: .contentType, value: type.description)
  }

  public static func location(_ location: String) -> Self {
    return .init(name: .location, value: location)
  }

  public static func setCookie(_ name: String, _ value: String, _ options: Set<CookieOption> = [])
    -> Self {

      let stringValue = ([name + "=" + value] + options.map(^\.description).sorted())
        .joined(separator: "; ")

      return .init(name: .setCookie, value: stringValue)
  }

  public static func wwwAuthenticate(_ authenticate: Authenticate) -> Self {
    switch authenticate {
    case let .basic(realm):
      let realmString = realm.map { " realm=\"" + $0 + "\"" } ?? ""
      return .init(name: .wwwAuthenticate, value: "Basic" + realmString)
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
    -> [HTTPField] {
      return pairs.map { .setCookie($0.key, $0.value, options) }
  }

  public static func clearCookie(_ name: String) -> HTTPField {
    return .setCookie(name, "", [.maxAge(0), .expires(Date(timeIntervalSince1970: 0))])
  }
}

private let expiresDateFormatter = DateFormatter()
  |> \.dateFormat .~ "EEE, d MMM yyyy HH:mm:ss zzz"
  |> \.locale .~ Locale(identifier: "en_US_POSIX")
  |> \.timeZone .~ TimeZone(abbreviation: "GMT")
