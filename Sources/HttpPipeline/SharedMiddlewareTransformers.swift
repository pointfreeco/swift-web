import Foundation
import Optics
import Prelude

public func filterMap<A, B, C>(
  _ f: @escaping (A) -> IO<B?>,
  or notFoundMiddleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, C>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, B, C>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, C> {

    return { middleware in
      { conn in

        f(conn.data).flatMap { result in
          result.map(middleware <<< conn.map <<< const)
            ?? notFoundMiddleware(conn)
        }
      }
    }
}

public func filter<A, B>(
  _ p: @escaping (A) -> Bool,
  or notFoundMiddleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, B>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, B>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, B> {

    return filterMap({ p($0) ? $0 : nil } >>> pure, or: notFoundMiddleware)
}

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
  failure: @escaping Middleware<HeadersOpen, ResponseEnded, A, Data> = respond(text: "Please authenticate.")
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

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
              >=> writeHeader(.wwwAuthenticate(.basic(realm: realm)))
              >=> failure
        )
      }
    }
}

public func notFound<A>(_ middleware: @escaping Middleware<HeadersOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {
    return writeStatus(.notFound)
      >=> middleware
}

/// Redirects requests whose hosts are not one of an allowed list. This can be useful for redirecting a
/// bare domain, e.g. http://pointfree.co, to a `www` domain, e.g. `http://www.pointfree.co`.
///
/// - Parameters:
///   - isAllowedHost: A predicate used to allow hosts.
///   - canonicalHost: The canonical host to redirect to if the host is not allowed.
/// - Returns:
public func redirectUnrelatedHosts<A>(
  isAllowedHost: @escaping (String) -> Bool,
  canonicalHost: String
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { middleware in
      { conn in
        conn.request.url
          .filter { !isAllowedHost($0.host ?? "") }
          .flatMap {
            URLComponents(url: $0, resolvingAgainstBaseURL: false)
              |> map(\.host .~ canonicalHost)
          }
          .flatMap(^\.url)
          .map { conn |> redirect(to: $0.absoluteString, status: .movedPermanently) }
          ?? middleware(conn)
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
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return redirectUnrelatedHosts(isAllowedHost: { allowedHosts.contains($0) }, canonicalHost: canonicalHost)
}

public func requireHerokuHttps<A>(allowedInsecureHosts: [String])
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { middleware in
      return { conn in
        conn.request.url
          .filter { url in
            // `url.scheme` cannot be trusted on Heroku, instead we need to look at the `X-Forwarded-Proto`
            // header to determine if we are on https or not.
            conn.request.allHTTPHeaderFields?["X-Forwarded-Proto"] != .some("https")
              && !allowedInsecureHosts.contains(url.host ?? "")
          }
          .flatMap(makeHttps)
          .map { conn |> redirect(to: $0.absoluteString, status: .movedPermanently) }
          ?? middleware(conn)
      }
    }
}

public func requireHttps<A>(allowedInsecureHosts: [String])
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { middleware in
      return { conn in
        conn.request.url
          .filter { (url: URL) -> Bool in
            url.scheme != .some("https")
              && !allowedInsecureHosts.contains(url.host ?? "")
          }
          .flatMap(makeHttps)
          .map { conn |> redirect(to: $0.absoluteString, status: .movedPermanently) }
          ?? middleware(conn)
      }
    }
}

public func validateBasicAuth(user: String, password: String, request: URLRequest) -> Bool {

  let auth = request.value(forHTTPHeaderField: "Authorization") ?? ""

  let parts = Foundation.Data(base64Encoded: String(auth.dropFirst(6)))
    .map { String(decoding: $0, as: UTF8.self) }
    .map { $0.split(separator: ":").map(String.init) }

  return parts?.first == .some(user) && parts?.last == .some(password)
}

private func makeHttps(url: URL) -> URL? {
  return URLComponents(url: url, resolvingAgainstBaseURL: false)
    |> map(\.scheme .~ "https")
    |> flatMap(^\.url)
}

/// Transforms middleware into one that logs the request info that comes through and logs the amount of
/// time the request took.
///
/// - Parameter logger: A function for logging strings.
public func requestLogger(logger: @escaping (String) -> Void, uuid: @escaping () -> UUID)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> {

    return { middleware in
      return { conn in
        let id = uuid().uuidString
        let startTime = Date().timeIntervalSince1970
        logger("\(id) [Request] \(conn.request.httpMethod ?? "GET") \(conn.request.url?.relativePath ?? "")")
        return middleware(conn).flatMap { b in
          IO {
            let endTime = Date().timeIntervalSince1970
            // NB: `absoluteString` is necessary because of https://github.com/apple/swift-corelibs-foundation/pull/1312
            logger("\(id) [Time] \(Int((endTime - startTime) * 1000))ms")
            return b
          }
        }
      }
    }
}
