import Css
import Html

extension Attribute where Element: HasFor {
  public static func `for`<T: HasFor>(_ idSelector: CssSelector) -> Attribute<T> {
    return .init("for", idSelector.idString ?? "")
  }
}

extension Attribute {
  public static func id<T>(_ idSelector: CssSelector) -> Attribute<T> {
    return .init("id", idSelector.idString ?? "")
  }
}

extension Attribute {
  public static func style<T>(_ style: Stylesheet) -> Attribute<T> {
    return .init("style", render(config: .inline, css: style))
  }
}

extension ChildOf where Element == Tag.Head {
  public static func style(
    attributes: [Attribute<Tag.Style>] = [],
    _ css: Stylesheet,
    config: Css.Config = .compact
  ) -> ChildOf<Tag.Head> {
      return .style(unsafe: render(config: config, css: css))
  }
}
