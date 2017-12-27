import Css
import Html

public func `for`<T: HasFor>(_ idSelector: CssSelector) -> Attribute<T> {
  return .init("for", idSelector.id ?? "")
}

public func id<T>(_ idSelector: CssSelector) -> Attribute<T> {
  return .init("id", idSelector.id ?? "")
}

public func style<T>(_ style: Stylesheet) -> Attribute<T> {
  return .init("style", style)
}

public func style(_ attribs: [Attribute<Element.Style>], _ css: Stylesheet) -> ChildOf<Element.Head> {
  return style(render(config: Css.compact, css: css))
}

public func style(_ css: Stylesheet) -> ChildOf<Element.Head> {
  return style([], css)
}

extension Stylesheet: Html.Value {
  public func render(with key: String) -> EncodedString? {
    return encode("\(key)=") + quote(encode(Css.render(config: inline, css: self)))
  }

  public func renderedValue() -> EncodedString? {
    return encode(Css.render(config: inline, css: self))
  }
}

public func `class`<T>(_ selectors: [CssSelector]) -> Attribute<T> {
  return .init(
    "class",
    renderedClassAttribute(classes: selectors)
  )
}
