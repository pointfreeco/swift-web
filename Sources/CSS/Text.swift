public struct Content: Val, None {
  let content: Value

  public func value() -> Value {
    return self.content
  }

  public static let none = Content(content: .none)
}

public func content(_ c: Content) -> Stylesheet {
  return key("content", c)
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

public func quotes(_ q: Quotes) -> Stylesheet {
  return key("quotes", q)
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
}

extension TextAlign: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(.init(stringLiteral: value))
  }
}

public let justify: TextAlign = "justify"
public let matchParent: TextAlign = "match-parent"
public let start: TextAlign = "start"
public let end: TextAlign = "end"

public let textAlign: (TextAlign) -> Stylesheet = key("text-align")
