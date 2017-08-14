public struct Content: Val, None {
  let content: Value

  public func value() -> Value {
    return self.content
  }

  public static let none = Content(content: .none)
}

public let content: (Content) -> Stylesheet = key("content")

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

public let quotes: (Quotes) -> Stylesheet = key("quotes")

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

public let textAlign: (TextAlign) -> Stylesheet = key("text-align")

public func letterSpacing(_ size: Css.Size) -> Stylesheet {
  return key("letter-spacing")(size)
}

public struct TextTransform: Val, None, Inherit {
  let transform: Css.Value

  public func value() -> Css.Value {
    return self.transform
  }

  public static let none = TextTransform(transform: .none)
  public static let inherit = TextTransform(transform: .inherit)
  public static let capitalize = TextTransform(transform: "capitalize")
  public static let uppercase = TextTransform(transform: "uppercase")
  public static let lowercase = TextTransform(transform: "lowercase")
  public static let fullWidth = TextTransform(transform: "full-width")
}

public func textTransform(_ transform: TextTransform) -> Stylesheet {
  return key("text-transform")(transform)
}
