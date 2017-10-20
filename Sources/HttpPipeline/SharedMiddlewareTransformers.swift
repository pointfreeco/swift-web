import Foundation
import Optics
import Prelude

/// Wraps basic auth middleware around existing middleware. Provides only the most basic of authentication
/// where the username and password are static, e.g. we do not look in a database for the user.
///
/// - Parameters:
///   - user: The user name to authenticate against.
///   - password: The password to authenticate against.
///   - realm: The realm.
///   - protect: An optional predicate that can further control what values of `A` are protected by basic auth.
///   - failure: An optional middleware to run in the case that authentication fails.
/// - Returns: Transformed middleware
public func basicAuth<A>(
  user: String,
  password: String,
  realm: String? = nil,
  protect: @escaping (A) -> Bool = const(true),
  failure: @escaping Middleware<HeadersOpen, ResponseEnded, A, Data?> = respond(text: "Please authenticate.")
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { middleware in
      return { conn in
        guard protect(conn.data)
          && !validateBasicAuth(user: user, password: password, request: conn.request)
          else {
            return middleware(conn)
        }

        return conn |>
          (
            writeStatus(.unauthorized)
              >-> writeHeader(.wwwAuthenticate(.basic(realm: realm)))
              >-> failure
        )
      }
    }
}

public func notFound<A>(_ middleware: @escaping Middleware<HeadersOpen, ResponseEnded, A, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {
    return writeStatus(.notFound)
      >-> middleware
}

public func contentLength<A, B>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, B>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, A, B> {

    return { conn in
      middleware(conn)
        .flatMap { conn in
          conn
            |> \.response.headers %~ { $0 + [.contentLength(conn.response.body?.count ?? 0)] }
            |> pure
      }
    }
}

/// Redirects requests whose hosts are not one of an allowed list. This can be useful for redirecting a
/// bare domain, e.g. http://pointfree.co, to a `www` domain, e.g. `http://www.pointfree.co`.
///
/// - Parameters:
///   - allowedHosts: A list of hosts that are allowed through without redirection.
///   - canonicalHost: The canonical host to redirect to if the host is not allowed.
/// - Returns:
public func redirectUnrelatedHosts<A>(
  allowedHosts: [String],
  canonicalHost: String
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { middleware in
      return { conn in
        conn.request.url
          .filterOptional { !allowedHosts.contains($0.host ?? "") }
          .flatMap {
            URLComponents(url: $0, resolvingAgainstBaseURL: false)
              |> map(\.host .~ canonicalHost)
          }
          .flatMap(get(\.url))
          .map {
            conn
              |> writeStatus(.movedPermanently)
              >-> writeHeader(.location($0.absoluteString))
              >-> end
          }
          ?? middleware(conn)
      }
    }
}

public func requireHerokuHttps<A>(allowedInsecureHosts: [String])
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { middleware in
      return { conn in
        conn.request.url
          .filterOptional { (url: URL) -> Bool in
            // `url.scheme` cannot be trusted on Heroku, instead we need to look at the `X-Forwarded-Proto`
            // header to determine if we are on https or not.
            conn.request.allHTTPHeaderFields?["X-Forwarded-Proto"] != .some("https")
              && !allowedInsecureHosts.contains(url.host ?? "")
          }
          .flatMap(makeHttps)
          .map {
            conn
              |> writeStatus(.movedPermanently)
              >-> writeHeader(.location($0.absoluteString))
              >-> end
          }
          ?? middleware(conn)
      }
    }
}

public func requireHttps<A>(allowedInsecureHosts: [String])
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { middleware in
      return { conn in
        conn.request.url
          .filterOptional { (url: URL) -> Bool in
            url.scheme != .some("https")
              && !allowedInsecureHosts.contains(url.host ?? "")
          }
          .flatMap(makeHttps)
          .map {
            conn
              |> writeStatus(.movedPermanently)
              >-> writeHeader(.location($0.absoluteString))
              >-> end
          }
          ?? middleware(conn)
      }
    }
}

public func validateBasicAuth(user: String, password: String, request: URLRequest) -> Bool {

  let auth = request.allHTTPHeaderFields?.first(where: { $0.key == "Authorization" })?.value ?? ""

  let parts = Foundation.Data(base64Encoded: String(auth.dropFirst(6)))
    .flatMap { String(data: $0, encoding: .utf8) }
    .map { $0.split(separator: ":").map(String.init) }

  return parts?.first == .some(user) && parts?.last == .some(password)
}

private func makeHttps(url: URL) -> URL? {
  return URLComponents(url: url, resolvingAgainstBaseURL: false)
    |> map(\.scheme .~ "https")
    |> flatMap { $0.url }
}

// TODO: move to prelude
extension Optional {
  fileprivate func filterOptional(_ p: (Wrapped) -> Bool) -> Optional {
    return self.flatMap { p($0) ? $0 : nil }
  }
}
