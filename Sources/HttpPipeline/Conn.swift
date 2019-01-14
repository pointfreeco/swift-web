import Foundation
import Prelude

public enum StatusLineOpen {}
public enum HeadersOpen {}
public enum BodyOpen {}
public enum ResponseEnded {}

public struct Conn<Step, A> {
  public var data: A
  public var request: URLRequest
  public var response: Response
}

public func connection(
  from request: URLRequest,
  defaultHeaders headers: [Response.Header] = [
//  .init("Content-Security-Policy", "script-src 'unsafe-inline'; style-src 'unsafe-inline'"),
  .init("Referrer-Policy", "strict-origin-when-cross-origin"),
  .init("X-Content-Type-Options", "nosniff"),
  .init("X-Download-Options", "noopen"),
  .init("X-Frame-Options", "SAMEORIGIN"),
  .init("X-Permitted-Cross-Domain-Policies", "none"),
  .init("X-XSS-Protection", "1; mode=block"),
  ]
  )
  -> Conn<StatusLineOpen, Prelude.Unit> {
  return .init(
    data: unit,
    request: request,
    response: Response(
      status: .ok,
      headers: headers,
      body: Data()
    )
  )
}

// MARK: - Functor

extension Conn {
  public func map<B>(_ f: (A) -> B) -> Conn<Step, B> {
    return .init(
      data: f(self.data),
      request: self.request,
      response: self.response
    )
  }

  public static func <¢> <B>(f: (A) -> B, c: Conn<Step, A>) -> Conn<Step, B> {
    return c.map(f)
  }
}

public func map<Step, A, B>(_ f: @escaping (A) -> B) -> (Conn<Step, A>) -> Conn<Step, B> {
  return { $0.map(f) }
}

// MARK: - Monad

extension Conn {
  public func flatMap<B>(_ f: (A) -> Conn<Step, B>) -> Conn<Step, B> {
    return f(self.data)
  }
}

public func flatMap<Step, A, B>(_ f: @escaping (A) -> Conn<Step, B>) -> (Conn<Step, A>) -> Conn<Step, B> {
  return { $0.flatMap(f) }
}
