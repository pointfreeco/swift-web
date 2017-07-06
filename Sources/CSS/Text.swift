public struct Content: Val, None {
  let content: Value

  public func value() -> Value {
    return self.content
  }

  public static var none: Content {
    return .init(content: noneValue)
  }
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

  public static var none: Quotes {
    return .init(quote: noneValue)
  }
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

  public static var normal: TextAlign {
    return .init(normalValue)
  }

  public static var inherit: TextAlign {
    return .init(inheritValue)
  }

  public static func other(_ other: Value) -> TextAlign {
    return .init(other)
  }

  public static var center: TextAlign {
    return .init(centerValue)
  }
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
