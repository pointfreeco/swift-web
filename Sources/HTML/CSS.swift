// NB: this could be moved to a separate package to glue HTML + CSS together.
import CSS

public func style(_ style: Stylesheet) -> Attribute {
  return Attribute("style", style)
}

public func style(_ css: Stylesheet) -> Node {
  return node(
    "style",
    [],
    [ .text(EncodedString(render(config: CSS.compact, css: css))) ]
  )
}

extension Stylesheet: Value {
  public func render(with key: String) -> EncodedString? {

    return encode("\(key)=") + quote(encode(CSS.render(config: inline, css: self)))
  }
}
