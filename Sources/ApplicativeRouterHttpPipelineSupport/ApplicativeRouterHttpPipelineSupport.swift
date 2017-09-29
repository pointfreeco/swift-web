import ApplicativeRouter
import Foundation
import HttpPipeline
import Prelude

/// Middleware transformer that performs routing via a router, and if a route is unrecognized runs the
/// `notFound` middleware supplied.
///
/// - Parameters:
///   - router: A router from `ApplicativeRouter`.
///   - notFound: Middleware to run if a route is not recognized.
public func route<I, A, Route>(
  router: Parser<I, Route>,
  notFound: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data?> = notFound(respond(text: "don't know that url"))
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, Route, Data?>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data?> {

    return { middleware in
      return { conn in

        router.match(conn.request)
          .map(const >>> conn.map >>> middleware)
          ?? notFound(conn)
      }
    }
}
