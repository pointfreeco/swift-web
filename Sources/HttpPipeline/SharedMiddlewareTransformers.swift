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
public func basicAuth<E, A>(
  user: String,
  password: String,
  realm: String? = nil,
  protect: @escaping (A) -> Bool = const(true),
  failure: @escaping Middleware<HeadersOpen, ResponseEnded, E, E, A, Data> = respond(text: "Please authenticate.")
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data> {

    return { middleware in
      return { conn in
        guard conn.data.map(protect).right != .some(false)
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

public func notFound<E, A>(_ middleware: @escaping Middleware<HeadersOpen, ResponseEnded, E, E, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data> {
    return writeStatus(.notFound)
      >-> middleware
}

/// Redirects requests whose hosts are not one of an allowed list. This can be useful for redirecting a
/// bare domain, e.g. http://pointfree.co, to a `www` domain, e.g. `http://www.pointfree.co`.
///
/// - Parameters:
///   - allowedHosts: A list of hosts that are allowed through without redirection.
///   - canonicalHost: The canonical host to redirect to if the host is not allowed.
/// - Returns:
public func redirectUnrelatedHosts<E, A>(
  allowedHosts: [String],
  canonicalHost: String
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data> {

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
              >-> ignoreBody
          }
          ?? middleware(conn)
      }
    }
}

public func requireHerokuHttps<E, A>(allowedInsecureHosts: [String])
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data> {

    return { middleware in
      return { conn in
        conn.request.url
          .filterOptional { url in
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
              >-> ignoreBody
          }
          ?? middleware(conn)
      }
    }
}

public func requireHttps<E, A>(allowedInsecureHosts: [String])
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data> {

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
              >-> ignoreBody
          }
          ?? middleware(conn)
      }
    }
}

public func validateBasicAuth(user: String, password: String, request: URLRequest) -> Bool {

  let auth = request.allHTTPHeaderFields?.first(where: { $0.key == "Authorization" })?.value ?? ""

  let parts = Foundation.Data(base64Encoded: String(auth.dropFirst(6)))
    .map { String(decoding: $0, as: UTF8.self) }
    .map { $0.split(separator: ":").map(String.init) }

  return parts?.first == .some(user) && parts?.last == .some(password)
}

private func makeHttps(url: URL) -> URL? {
  return URLComponents(url: url, resolvingAgainstBaseURL: false)
    |> map(\.scheme .~ "https")
    |> flatMap { $0.url }
}


/// Transforms middleware into one that logs the request info that comes through and logs the amount of
/// time the request took.
public func requestLogger(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Never, Never, Prelude.Unit, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, Never, Never, Prelude.Unit, Data> {
    return requestLogger(logger: { print($0) })(middleware)
}


/// Transforms middleware into one that logs the request info that comes through and logs the amount of
/// time the request took.
///
/// - Parameter logger: A function for logging strings.
public func requestLogger(logger: @escaping (String) -> Void)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, Never, Never, Prelude.Unit, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, Never, Never, Prelude.Unit, Data> {

    return { middleware in
      return { conn in
        let startTime = Date().timeIntervalSince1970
        return middleware(conn).flatMap { b in
          IO {
            let endTime = Date().timeIntervalSince1970
            logger("[Request] \(conn.request.httpMethod ?? "GET") \(conn.request)")
            logger("[Time]    \(Int((endTime - startTime) * 1000))ms")
            return b
          }
        }
      }
    }
}

// TODO: move to prelude
extension Optional {
  fileprivate func filterOptional(_ p: (Wrapped) -> Bool) -> Optional {
    return self.flatMap { p($0) ? $0 : nil }
  }
}
