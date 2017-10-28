import Foundation
import Prelude

public enum StatusLineOpen {}
public enum HeadersOpen {}
public enum BodyOpen {}
public enum ResponseEnded {}

public struct Conn<Step, A> {
  public private(set) var data: A
  public private(set) var request: URLRequest
  public private(set) var response: Response
}

public func connection(from request: URLRequest) -> Conn<StatusLineOpen, Prelude.Unit> {
  return .init(
    data: unit,
    request: request,
    response: Response(status: .ok, headers: [], body: Data())
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

  public static func >>- <B>(_ x: Conn, f: @escaping (A) -> Conn<Step, B>) -> Conn<Step, B> {
    return x.flatMap(f)
  }
}

public func flatMap<Step, A, B>(_ f: @escaping (A) -> Conn<Step, B>) -> (Conn<Step, A>) -> Conn<Step, B> {
  return { $0.flatMap(f) }
}
