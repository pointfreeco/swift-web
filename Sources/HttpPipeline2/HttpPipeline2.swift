import Foundation
import NIO
import NIOHTTP1

public enum StatusLineOpen {}
public enum HeadersOpen {}
public enum BodyOpen {}
public enum ResponseEnded {}

public struct Request {
  public var head: HTTPRequestHead
  public var body: Data
}

public struct Conn<Step, Value> {
  public var channel: Channel
  public var request: Request
  public var value: Value
}

public typealias Middleware<I, J, A, B> = (Conn<I, A>) -> EventLoopFuture<Conn<J, B>>
