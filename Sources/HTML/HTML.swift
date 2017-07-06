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
  let name: String
  let attribs: [Attribute]
  let content: [Node]?
}

public struct Attribute {
  let key: String
  let value: Value

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
    return HTML.encode("\(key)=") + quote(HTML.encode(self))
  }
}

extension Int: Value {
  public func render(with key: String) -> EncodedString? {
    return HTML.encode("\(key)=") + quote(HTML.encode(String(self)))
  }
}

extension Bool: Value {
  public func render(with key: String) -> EncodedString? {
    return self ? HTML.encode(key) : nil
  }
}
