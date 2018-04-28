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

extension Node: Sequence {
  public func makeIterator() -> AnyIterator<Node> {
    var stack = [self]

    return AnyIterator<Node> {
      guard let next = stack.popLast() else {
        return nil
      }
      switch next {
      case .comment, .text:
        return next
      case  .element(let element):
        if let content = element.content {
          stack.append(contentsOf: content.reversed())
        }
        return next
      case .document(let nodes):
        stack.append(contentsOf: nodes.reversed())
        return next
      }
    }
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
    return self.renderedValue().map { Html.encode(key + "=") + quote($0) } ?? Html.encode(key)
  }
}

extension Value where Self: RawRepresentable, Self.RawValue: Value {
  public func renderedValue() -> EncodedString? {
    return self.rawValue.renderedValue()
  }
}

extension Bool: Value {
  public func render(with key: String) -> EncodedString? {
    return self ? Html.encode(key) : nil
  }

  public func renderedValue() -> EncodedString? {
    return nil
  }
}

extension Double: Value {
  public func renderedValue() -> EncodedString? {
    return Html.encode(String(self))
  }
}

extension Int: Value {
  public func renderedValue() -> EncodedString? {
    return Html.encode(String(self))
  }
}

extension String: Value {
  public func renderedValue() -> EncodedString? {
    return Html.encode(self)
  }
}
