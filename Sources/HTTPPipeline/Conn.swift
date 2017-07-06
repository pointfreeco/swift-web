import Foundation
import Prelude

public struct Conn<Step, Data> {
  public private(set) var data: Data
  public private(set) var request: URLRequest
  public private(set) var response: Response

  public func map<A>(_ f: (Data) -> A) -> Conn<Step, A> {
    return .init(
      data: f(self.data),
      request: self.request,
      response: self.response
    )
  }

  public func flatMap<A>(_ f: (Data) -> Conn<Step, A>) -> Conn<Step, A> {
    return f(self.data)
  }
}

public func map<Step, A, B>(_ f: @escaping (A) -> B) -> (Conn<Step, A>) -> Conn<Step, B> {
  return { $0.map(f) }
}

public func <¢> <Step, A, B> (f: (A) -> B, c: Conn<Step, A>) -> Conn<Step, B> {
  return c.map(f)
}

public func flatMap<Step, A, B>(_ f: @escaping (A) -> Conn<Step, B>) -> (Conn<Step, A>) -> Conn<Step, B> {
  return { $0.flatMap(f) }
}

public func connection(from request: URLRequest) -> Conn<StatusLineOpen, Prelude.Unit> {
  return .init(
    data: unit,
    request: request,
    response: Response(status: .ok, headers: [], body: "")
  )
}

public enum StatusLineOpen {}
public enum HeadersOpen {}
public enum BodyOpen {}
public enum ResponseEnded {}
