import NIO

public enum StatusLineOpen {}
public enum HeadersOpen {}
public enum BodyOpen {}
public enum ResponseEnded {}

public struct Conn<Step, Value> {
  public var channel: Channel
  public var request: Request
  public var response: Response
  public var value: Value

  public func map<NewValue>(_ transform: (Value) -> NewValue) -> Conn<Step, NewValue> {
    return Conn<Step, NewValue>(
      channel: self.channel,
      request: self.request,
      response: self.response,
      value: transform(self.value)
    )
  }
}
