import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Html
import HTTPTypes
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
  from request: URLRequest
  )
  -> Conn<StatusLineOpen, Prelude.Unit> {
  return .init(
    data: unit,
    request: request,
    response: Response(
      status: .ok,
      headers: [:],
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

// MARK: - Helpers

extension Conn where Step == StatusLineOpen {
  public func writeStatus(_ status: Status) -> Conn<HeadersOpen, A> {
    var response = self.response
    response.status = status
    return .init(
      data: self.data,
      request: self.request,
      response: response
    )
  }

  public func head(_ status: Status) -> Conn<ResponseEnded, Data> {
    self.writeStatus(status).empty()
  }

  public func redirect(
    to location: String,
    status: Status = .found,
    headersMiddleware: (Conn<HeadersOpen, A>) -> Conn<HeadersOpen, A> = { $0 }
  ) -> Conn<ResponseEnded, Data> {
    headersMiddleware(
      self.writeStatus(status)
    )
    .writeHeader(.location(location))
    .empty()
  }

  public func redirect(
    to location: String,
    status: Status = .found,
    headersMiddleware: (Conn<HeadersOpen, A>) async -> Conn<HeadersOpen, A> = { $0 }
  ) async -> Conn<ResponseEnded, Data> {
    await headersMiddleware(
      self.writeStatus(status)
    )
    .writeHeader(.location(location))
    .empty()
  }
}

extension Conn where Step == HeadersOpen {
  public func writeHeader(_ header: HTTPField) -> Self {
    var conn = self
    conn.response.headers.append(header)
    return conn
  }

  public func writeHeaders(_ header: HTTPFields) -> Self {
    var conn = self
    conn.response.headers.append(contentsOf: header)
    return conn
  }

  public func writeHeader(_ name: HTTPField.Name, _ value: String) -> Self {
    self.writeHeader(.init(name: name, value: value))
  }

  public func closeHeaders() -> Conn<BodyOpen, A> {
    .init(
      data: self.data,
      request: self.request,
      response: self.response
    )
  }

  public func empty() -> Conn<ResponseEnded, Data> {
    self.closeHeaders().map { _ in Data() }.end()
  }

  public func respond(text: String) -> Conn<ResponseEnded, Data> {
    self.respond(body: text, contentType: .plain)
  }

  public func respond(html: String) -> Conn<ResponseEnded, Data> {
    self.respond(body: html, contentType: .html)
  }

  public func respond(json: String) -> Conn<ResponseEnded, Data> {
    self.respond(body: json, contentType: .json)
  }

  public func respond(body: String, contentType: MediaType) -> Conn<ResponseEnded, Data> {
    let data = Data(body.utf8)
    return self.map { _ in data }
      .writeHeader(.contentType(contentType))
      .writeHeader(.contentLength(data.count))
      .closeHeaders()
      .end()
  }
}

extension Conn where Step == BodyOpen, A == Data {
  public func end() -> Conn<ResponseEnded, Data> {
    .init(
      data: self.data,
      request: self.request,
      response: Response(
        status: self.response.status,
        headers: self.response.headers,
        body: self.data
      )
    )
  }

  public func send(_ data: Data) -> Self {
    var conn = self
    conn.data.append(data)
    conn.response.body.append(data)
    return conn
  }
}
