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
  public static let italic = FontStyle(style: "italic")
}

public struct FontWeight: Val, Inherit, Initial, Normal {
  let weight: Value

  public func value() -> Value {
    return self.weight
  }

  public static let inherit = FontWeight(weight: .inherit)
  public static let initial = FontWeight(weight: .initial)
  public static let normal = FontWeight(weight: .normal)

  public static let bold = FontWeight(weight: "bold")
  public static let bolder = FontWeight(weight: "bolder")
  public static let lighter = FontWeight(weight: "light")
  public static let w100 = FontWeight(weight: "100")
  public static let w200 = FontWeight(weight: "200")
  public static let w300 = FontWeight(weight: "300")
  public static let w400 = FontWeight(weight: "400")
  public static let w500 = FontWeight(weight: "500")
  public static let w600 = FontWeight(weight: "600")
  public static let w700 = FontWeight(weight: "700")
  public static let w800 = FontWeight(weight: "800")
  public static let w900 = FontWeight(weight: "900")
}

public func color(_ color: Color) -> Stylesheet { return key("color", color) }
public let font: (Color) -> Stylesheet = key("font")
public let fontFamily: (GenericFontFamily) -> Stylesheet = key("font-family")

public func fontFamily(_ families: [String]) -> Stylesheet {
  return key(
    "font-family",
    Value(.plain(families.joined(separator: ",")))
  )
}

public let fontSize: (Size) -> Stylesheet = key("font-size")
public let fontStyle: (FontStyle) -> Stylesheet = key("font-style")
public let fontWeight: (FontWeight) -> Stylesheet = key("font-weight")
public let lineHeight: (Size) -> Stylesheet = key("line-height")
