import Either
import Foundation
import Prelude

public enum StatusLineOpen {}
public enum HeadersOpen {}
public enum BodyOpen {}
public enum ResponseEnded {}

public struct Conn<I, E, A> {
  public private(set) var data: Either<E, A>
  public private(set) var request: URLRequest
  public private(set) var response: Response
}

public func connection(from request: URLRequest) -> Conn<StatusLineOpen, Never, Prelude.Unit> {
  return .init(
    data: .right(unit),
    request: request,
    response: Response(status: .ok, headers: [], body: Data())
  )
}

// MARK: - Functor

extension Conn {
  public func map<B>(_ f: (A) -> B) -> Conn<I, E, B> {
    return .init(
      data: self.data.map(f),
      request: self.request,
      response: self.response
    )
  }

  public func map<B, F>(_ f: (Either<E, A>) -> Either<F, B>) -> Conn<I, F, B> {
    return Conn<I, F, B>(
      data: f(self.data),
      request: self.request,
      response: self.response
    )
  }

  public func bimap<B, F>(_ e2f: (E) -> F, _ a2b: (A) -> B) -> Conn<I, F, B> {
    return .init(
      data: self.data.bimap(e2f, a2b),
      request: self.request,
      response: self.response
    )
  }

  public static func <¢> <B>(f: (A) -> B, c: Conn<I, E, A>) -> Conn<I, E, B> {
    return c.map(f)
  }
}

public func map<I, E, A, B>(_ f: @escaping (A) -> B) -> (Conn<I, E, A>) -> Conn<I, E, B> {
  return { $0.map(f) }
}

// MARK: - Monad

extension Conn {
  public func flatMap<B>(_ f: (A) -> Conn<I, E, B>) -> Conn<I, E, B> {
    switch self.data.map(f) {
    case let .left(e):
      return .init(
        data: .left(e),
        request: self.request,
        response: self.response
      )
    case let .right(conn):
      return conn
    }
  }

  public static func >>- <B>(_ x: Conn, f: @escaping (A) -> Conn<I, E, B>) -> Conn<I, E, B> {
    return x.flatMap(f)
  }
}

public func flatMap<I, E, A, B>(_ f: @escaping (A) -> Conn<I, E, B>) -> (Conn<I, E, A>) -> Conn<I, E, B> {
  return { $0.flatMap(f) }
}
