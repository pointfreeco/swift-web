import Css
import Html

public func `for`<T: HasFor>(_ idSelector: CssSelector) -> Attribute<T> {
  return .init("for", idSelector.idString ?? "")
}

public func id<T>(_ idSelector: CssSelector) -> Attribute<T> {
  return .init("id", idSelector.idString ?? "")
}

public func style<T>(_ style: Stylesheet) -> Attribute<T> {
  return .init("style", Css.render(config: .inline, css: style))
}

public func style(
  _ attribs: [Attribute<Element.Style>],
  _ css: Stylesheet,
  config: Css.Config = .compact
  )
  -> ChildOf<Element.Head> {
    return style(render(config: config, css: css))
}

public func style(_ css: Stylesheet, config: Css.Config = .compact) -> ChildOf<Element.Head> {
  return style([], css, config: config)
}
