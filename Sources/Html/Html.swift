import Prelude

public enum Node {
  case comment(EncodedString)
  indirect case document([Node])
  case element(Element)
  case text(EncodedString)

  public var element: Element? {
    if case let .element(element) = self { return element }
    return nil
  }
}

extension Node: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .text(encode(value))
  }
}

public struct ChildOf<T> {
  public let node: Node

  public init(_ node: Node) {
    self.node = node
  }
}

public struct Element {
  fileprivate(set) public var name: String
  fileprivate(set) public var attribs: [AnyAttribute]
  fileprivate(set) public var content: [Node]?
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

public func node<T>(_ name: StaticString, _ attribs: [Attribute<T>], _ content: [Node]?) -> Node {
  return .element(.init(name: String(describing: name), attribs: attribs.map(^\.attrib), content: content))
}

public func node(_ name: StaticString, _ content: [Node]?) -> Node {
  return .element(.init(name: String(describing: name), attribs: [], content: content))
}

public func text(_ content: String) -> Node {
  return .text(encode(content))
}

public func attribute<T>(_ name: StaticString, _ value: Value) -> Attribute<T> {
  return .init(String(describing: name), value)
}

public func comment(_ content: StaticString) -> Node {
  return .comment(EncodedString(content))
}

public func comment<T>(_ content: StaticString) -> ChildOf<T> {
  return .init(comment(content))
}

extension Value {
  public func render(with key: String) -> EncodedString? {

    if let boolValue = self as? Bool {
      return boolValue
        ? Html.encode(key)
        : nil
    }

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
