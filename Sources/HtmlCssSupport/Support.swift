import Css
import Html

public func style(_ style: Stylesheet) -> Attribute {
  return .init("style", style)
}

public func style(_ css: Stylesheet) -> Node {
  return style(render(config: Css.compact, css: css))
}

extension Stylesheet: Html.Value {
  public func render(with key: String) -> EncodedString? {
    return encode("\(key)=") + quote(encode(Css.render(config: inline, css: self)))
  }
}
