import Css
import Html

public func `for`<T: HasFor>(_ idSelector: CssSelector) -> Attribute<T> {
  return .init("for", idSelector.idString ?? "")
}

public func id<T>(_ idSelector: CssSelector) -> Attribute<T> {
  return .init("id", idSelector.idString ?? "")
}

public func style<T>(_ style: Stylesheet) -> Attribute<T> {
  return .init("style", render(config: Config.inline, css: style))
}

public func style(
  _ attribs: [Attribute<Tag.Style>],
  _ css: Stylesheet,
  config: Css.Config = .compact
  )
  -> ChildOf<Tag.Head> {
    return style(render(config: config, css: css))
}

public func style(_ css: Stylesheet, config: Css.Config = .compact) -> ChildOf<Tag.Head> {
  return style([], css, config: config)
}

//extension Stylesheet: Html.Value {
//  public func render(with key: String) -> EncodedString? {
//    return encode("\(key)=") + quote(encode(Css.render(config: .inline, css: self)))
//  }
//
//  public func renderedValue() -> EncodedString? {
//    return encode(Css.render(config: .inline, css: self))
//  }
//}
