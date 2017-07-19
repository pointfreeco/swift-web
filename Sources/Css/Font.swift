public protocol Font: Val, Inherit {
  func font() -> Stylesheet
}

extension Font {
  public func font() -> Stylesheet {
    return key("font", self)
  }
}

public struct FontSize: Val {
  let size: Value

  public func value() -> Value {
    return self.size
  }
}

public struct GenericFontFamily: Val, Inherit {
  let family: Value

  public func value() -> Value {
    return self.family
  }

  public static let inherit = GenericFontFamily(family: .inherit)
}

public struct FontStyle: Val, Inherit {
  public let style: Value

  public func value() -> Value {
    return self.style
  }

  public static let inherit = FontStyle(style: .inherit)
}

public struct FontWeight: Val, Inherit {
  let weight: Value

  public func value() -> Value {
    return self.weight
  }

  public static let inherit = FontWeight(weight: .inherit)

  public static let bold = FontWeight(weight: .init(.plain("bold")))

  public static func weight(_ weight: Int) -> FontWeight {
    return .init(weight: .init(.plain(String(weight))))
  }
}

extension Stylesheet {
  public static let color: (Color) -> Stylesheet = key("color")
  public static let font: (Color) -> Stylesheet = key("font")
  public static let fontFamily: (GenericFontFamily) -> Stylesheet = key("font-family")

  public func fontFamily(_ families: [String]) -> Stylesheet {
    return key(
      "font-family",
      Value(.plain(families.joined(separator: ",")))
    )
  }

  public static let fontSize: (Size) -> Stylesheet = key("font-size")
  public static let fontStyle: (FontStyle) -> Stylesheet = key("font-style")
  public static let fontWeight: (FontWeight) -> Stylesheet = key("font-weight")
  public static let lineHeight: (Size) -> Stylesheet = key("line-height")
}
