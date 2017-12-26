import Foundation
import Html
import HttpPipeline
import Prelude

public func respond<A>(_ view: View<A>) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return { conn in
    conn |> respond(body: view.rendered(with: conn.data), contentType: .html)
  }
}

/// Lifts middleware that operates on non-optional values to one that operates on optionals, but renders
/// a 404 not found view in place of `nil` values.
///
/// - Parameter notFoundView: A view to render in case of encountering a `nil` value.
/// - Returns: New middleware that operates on optional values.
public func requireSome<A>(
  notFoundView: View<Prelude.Unit>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A?, Data> {

    return { middleware in
      return { conn in
        return conn.data
          .map { conn.map(const($0)) }
          .map(middleware)
          ?? (conn.map(const(unit)) |> (writeStatus(.notFound) >-> respond(notFoundView)))
      }
    }
}

/// Given a function that can optionally extract a `B` value out of an `A` value, this middleware transformer
/// requires that the output be non-optional, and in the case of `nil` will route to a not found 404 page.
public func require<A, B>(
  _ f: @escaping (A) -> B?,
  notFoundView: View<A> = View { _ in ["Not found"] }
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, B, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { middleware in
      return { conn in
        return f(conn.data)
          .map { conn.map(const($0)) }
          .map(middleware)
          ?? (conn |> (writeStatus(.notFound) >-> respond(notFoundView)))
      }
    }
}
