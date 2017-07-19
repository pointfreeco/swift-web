public protocol Font: Val, Inherit {
  func font() -> Stylesheet
}

extension Font {
  public func font() -> Stylesheet {
    return key("font", self)
  }
}

public func color(_ c: Color) -> Stylesheet {
  return key("color", c)
}

public func lineHeight(_ size: Size) -> Stylesheet {
  return key("line-height", size)
}

public struct FontSize: Val {
  let size: Value

  public func value() -> Value {
    return self.size
  }
}

public func fontSize(_ size: Size) -> Stylesheet {
  return key("font-size", size)
}

public func font<F: Font>(_ f: F) -> Stylesheet {
  return key("font", f)
}

public struct GenericFontFamily: Val, Inherit {
  let family: Value

  public func value() -> Value {
    return self.family
  }

  public static let inherit = GenericFontFamily(family: .inherit)
}

public func fontFamily(_ families: [String]) -> Stylesheet {
  return key(
    "font-family",
    Value(.plain(families.joined(separator: ",")))
  )
}

public func fontFamily(_ family: GenericFontFamily) -> Stylesheet {
  return key("font-family", family)
}

public struct FontStyle: Val, Inherit {
  public let style: Value

  public func value() -> Value {
    return self.style
  }

  public static let inherit = FontStyle(style: .inherit)
}

public func fontStyle(_ style: FontStyle) -> Stylesheet {
  return key("font-style", style)
}

public struct FontWeight: Val, Inherit {
  let weight: Value

  public func value() -> Value {
    return self.weight
  }

  public static let inherit = FontWeight(weight: .inherit)
}

public let bold = FontWeight(weight: .init(.plain("bold")))

public func weight(_ w: Int) -> FontWeight {
  return .init(weight: .init(.plain(String(w))))
}

public func fontWeight(_ weight: FontWeight) -> Stylesheet {
  return key("font-weight", weight)
}
