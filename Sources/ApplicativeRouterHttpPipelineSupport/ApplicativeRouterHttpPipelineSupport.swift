import ApplicativeRouter
import Foundation
import HttpPipeline
import Prelude

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
