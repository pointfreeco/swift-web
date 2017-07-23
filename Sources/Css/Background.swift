public protocol Background: Val {
  func background() -> Stylesheet
}

extension Background {
  public func background() -> Stylesheet {
    return key("background", self)
  }
}

extension Stylesheet {
  public static func background<B: Background>(_ b: B) -> Stylesheet {
    return b.background()
  }
}

extension Color: Background {}
