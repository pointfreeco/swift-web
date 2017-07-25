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
  public let attribs: [AnyAttribute]
  public let content: [Node]?
}

public struct AnyAttribute {
  public let key: String
  public let value: Value

  public init(_ key: String, _ value: Value) {
    self.key = key
    self.value = value
  }
}

public struct Attribute<T> {
  public let attrib: AnyAttribute

  public init(_ key: String, _ value: Value) {
    self.attrib = .init(key, value)
  }
}

public protocol Value {
  func renderedValue() -> EncodedString?
  func render(with key: String) -> EncodedString?
}

public func document(_ content: [Node]) -> Node {
  return .document(content)
}

public func node<T>(_ name: String, _ attribs: [Attribute<T>], _ content: [Node]?) -> Node {
  return .element(.init(name: name, attribs: attribs.map(get(\.attrib)), content: content))
}

public func node(_ name: String, _ content: [Node]?) -> Node {
  return .element(.init(name: name, attribs: [], content: content))
}

public func text(_ content: String) -> Node {
  return .text(encode(content))
}

public func attribute<T>(_ name: String, _ value: Value) -> Attribute<T> {
  return .init(name, value)
}

extension Value {
  public func render(with key: String) -> EncodedString? {
    return self.renderedValue().map { Html.encode("\(key)=") + quote($0) } ?? Html.encode(key)
  }

  public func renderedValue() -> EncodedString? {
    return Html.encode("\(self)")
  }
}

extension Value where Self: CustomStringConvertible {
  public func renderedValue() -> EncodedString? {
    return Html.encode(self.description)
  }
}

extension Value where Self: RawRepresentable, Self.RawValue: Value {
  public func renderedValue() -> EncodedString? {
    return self.rawValue.renderedValue()
  }
}

extension Bool: Value {
  public func renderedValue() -> EncodedString? {
    return nil
  }
}

extension Double: Value {}
extension Int: Value {}
extension String: Value {}
