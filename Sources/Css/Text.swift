public struct Content: Val, None {
  let content: Value

  public func value() -> Value {
    return self.content
  }

  public static let none = Content(content: .none)
}

extension Stylesheet {
  public static let content: (Content) -> Stylesheet = key("content")
}

public func stringContent(_ s: String) -> Content {
  return .init(content: Literal(s).value())
}

public struct Quotes: Val, None {
  let quote: Value

  public func value() -> Value {
    return self.quote
  }

  public static let none = Quotes(quote: .none)
}

extension Stylesheet {
  public static let quotes: (Quotes) -> Stylesheet = key("quotes")
}

public struct TextAlign: Val, Normal, Inherit, Other, Center {
  let textAlign: Value

  init(_ textAlign: Value) {
    self.textAlign = textAlign
  }

  public func value() -> Value {
    return self.textAlign
  }

  public static func other(_ other: Value) -> TextAlign {
    return .init(other)
  }

  public static let center = TextAlign(.center)
  public static let normal = TextAlign(.normal)
  public static let inherit = TextAlign(.inherit)

  public static let justify: TextAlign = "justify"
  public static let matchParent: TextAlign = "match-parent"
  public static let start: TextAlign = "start"
  public static let end: TextAlign = "end"
}

extension TextAlign: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(.init(stringLiteral: value))
  }
}

extension Stylesheet {
  public static let textAlign: (TextAlign) -> Stylesheet = key("text-align")
}
