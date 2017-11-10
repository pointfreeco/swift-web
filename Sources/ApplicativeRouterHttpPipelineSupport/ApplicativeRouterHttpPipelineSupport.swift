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
public func route<E, A, Route>(
  router: Router<Route>,
  notFound: @escaping Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data> = notFound(respond(text: "Not Found"))
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, E, E, Route, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, E, E, A, Data> {

    return { middleware in
      { conn in

        router.match(request: conn.request)
          .map(const >>> conn.map >>> middleware)
          ?? notFound(conn)
      }
    }
}
