import Prelude

public enum Node {
  case comment(String)
  indirect case document([Node])
  case element(Element)
  case text(EncodedString)
}

extension Node: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .text(encode(value))
  }
}

public struct Element {
  public let name: String
  public let attribs: [Attribute]
  public let content: [Node]?
}

public struct Attribute {
  public let key: String
  public let value: Value

  public init(_ key: String, _ value: Value) {
    self.key = key
    self.value = value
  }
}

public protocol Value {
  func render(with key: String) -> EncodedString?
}

public func document(_ content: [Node]) -> Node {
  return .document(content)
}

public func node(_ name: String, _ attribs: [Attribute], _ content: [Node]?) -> Node {
  return .element(.init(name: name, attribs: attribs, content: content))
}

public func node(_ name: String, _ content: [Node]?) -> Node {
  return .element(.init(name: name, attribs: [], content: content))
}

public func text(_ text: String) -> Node {
  return .text(encode(text))
}

extension String: Value {
  public func render(with key: String) -> EncodedString? {
    return Html.encode("\(key)=") + quote(Html.encode(self))
  }
}

extension Int: Value {
  public func render(with key: String) -> EncodedString? {
    return Html.encode("\(key)=") + quote(Html.encode(String(self)))
  }
}

extension Bool: Value {
  public func render(with key: String) -> EncodedString? {
    return self ? Html.encode(key) : nil
  }
}
