import Prelude

public struct Appearance: Val, None {
  let appearance: Value

  public func value() -> Value {
    return self.appearance
  }

  public static let button = Appearance(appearance: "button")
  public static let field = Appearance(appearance: "field")
  public static let icon = Appearance(appearance: "icon")
  public static let menu = Appearance(appearance: "menu")
  public static let none = Appearance(appearance: .none)
  public static let normal = Appearance(appearance: "normal")
  public static let window = Appearance(appearance: "window")
}

public func appearance(_ appearance: Appearance) -> Stylesheet {
  return prefixed(supportedBrowsers <> "appearance", appearance)
}

private let supportedBrowsers = Prefixed.prefixed(
  [
    ("-webkit-", ""),
    ("-moz-", ""),
    ("", "")
  ]
)
