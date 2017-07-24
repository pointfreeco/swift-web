extension Element {
  public enum A: HasHref, HasRel, HasTarget {}
  public enum Area: HasHref, HasRel, HasTarget {}
  public enum Article {}
  public enum Aside {}
  public enum Audio: HasSrc {}
  public enum Body {}
  public enum Base: HasHref, HasTarget {}
  public enum Button: HasAutofocus, HasDisabled, HasName, HasValue {}
  public enum Canvas: HasHeight, HasWidth {}
  public enum Div {}
  public enum Embed: HasHeight, HasSrc, HasMediaType, HasWidth {}
  public enum Fieldset: HasDisabled, HasName, HasTarget {}
  public enum Form: HasName {}
  public enum Footer {}
  public enum H1 {}
  public enum H2 {}
  public enum H3 {}
  public enum H4 {}
  public enum H5 {}
  public enum H6 {}
  public enum Header {}
  public enum Html {}
  public enum Iframe: HasHeight, HasName, HasSrc, HasWidth {}
  public enum Img: HasHeight, HasSrc, HasWidth {}
  public enum Input: HasAutofocus, HasDisabled, HasHeight, HasMax, HasMaxlength, HasMin, HasMinlength,
    HasMultiple, HasName, HasPlaceholder, HasReadonly, HasRequired, HasSrc, HasValue, HasWidth {}
  public enum Keygen: HasAutofocus, HasDisabled, HasName {}
  public enum Label: HasFor {}
  public enum Li: HasValue {}
  public enum Link: HasHref, HasRel, HasMediaType {}
  public enum Main {}
  public enum Map: HasName {}
  public enum Menu {}
  public enum Meta: HasCharset, HasName {}
  public enum Meter: HasMax, HasMin {}
  public enum Nav {}
  public enum Object: HasHeight, HasName, HasMediaType, HasWidth {}
  public enum Ol {}
  public enum Optgroup: HasDisabled {}
  public enum Option: HasDisabled, HasValue {}
  public enum Output: HasFor, HasName {}
  public enum P {}
  public enum Param: HasName, HasValue {}
  public enum Progress: HasMax {}
  public enum Script: HasCharset, HasSrc, HasMediaType {}
  public enum Select: HasAutofocus, HasDisabled, HasMultiple, HasName, HasRequired {}
  public enum Source: HasSrc, HasMediaType {}
  public enum Span {}
  public enum Style: HasMediaType {}
  public enum Track: HasSrc {}
  public enum Textarea: HasAutofocus, HasDisabled, HasMaxlength, HasMinlength, HasName, HasPlaceholder,
    HasReadonly, HasRequired {}
  public enum Ul {}
  public enum Video: HasHeight, HasSrc, HasWidth {}
}

public func a(_ attribs: [Attribute<Element.A>], _ content: [Node]) -> Node {
  return node("a", attribs, content)
}

public func a(_ content: [Node]) -> Node {
  return a([], content)
}

public func article(_ attribs: [Attribute<Element.Article>], _ content: [Node]) -> Node {
  return node("article", attribs, content)
}

public func article(_ content: [Node]) -> Node {
  return article([], content)
}

public func aside(_ attribs: [Attribute<Element.Aside>], _ content: [Node]) -> Node {
  return node("aside", attribs, content)
}

public func aside(_ content: [Node]) -> Node {
  return aside([], content)
}

public func body(_ attribs: [Attribute<Element.Body>], _ content: [Node]) -> Node {
  return node("body", attribs, content)
}

public func body(_ content: [Node]) -> Node {
  return body([], content)
}

public func button(_ attribs: [Attribute<Element.Button>], _ content: [Node]) -> Node {
  return node("button", attribs, content)
}

public func button(_ content: [Node]) -> Node {
  return button([], content)
}

public func div(_ attribs: [Attribute<Element.Div>], _ content: [Node]) -> Node {
  return node("div", attribs, content)
}

public func div(_ content: [Node]) -> Node {
  return div([], content)
}

public func footer(_ attribs: [Attribute<Element.Footer>], _ content: [Node]) -> Node {
  return node("footer", attribs, content)
}

public func footer(_ content: [Node]) -> Node {
  return footer([], content)
}

public func form(_ attribs: [Attribute<Element.Form>], _ content: [Node]) -> Node {
  return node("form", attribs, content)
}

public func form(_ content: [Node]) -> Node {
  return form([], content)
}

public func h1(_ attribs: [Attribute<Element.H1>], _ content: [Node]) -> Node {
  return node("h1", attribs, content)
}

public func h1(_ content: [Node]) -> Node {
  return h1([], content)
}

public func h2(_ attribs: [Attribute<Element.H2>], _ content: [Node]) -> Node {
  return node("h2", attribs, content)
}

public func h2(_ content: [Node]) -> Node {
  return h2([], content)
}

public func h3(_ attribs: [Attribute<Element.H3>], _ content: [Node]) -> Node {
  return node("h3", attribs, content)
}

public func h3(_ content: [Node]) -> Node {
  return h3([], content)
}

public func h4(_ attribs: [Attribute<Element.H4>], _ content: [Node]) -> Node {
  return node("h4", attribs, content)
}

public func h4(_ content: [Node]) -> Node {
  return h4([], content)
}

public func h5(_ attribs: [Attribute<Element.H5>], _ content: [Node]) -> Node {
  return node("h5", attribs, content)
}

public func h5(_ content: [Node]) -> Node {
  return h5([], content)
}

public func h6(_ attribs: [Attribute<Element.H6>], _ content: [Node]) -> Node {
  return node("h6", attribs, content)
}

public func h6(_ content: [Node]) -> Node {
  return h6([], content)
}

public func head(_ content: [Node]) -> Node {
  return node("head", content)
}

public func header(_ attribs: [Attribute<Element.Header>], _ content: [Node]) -> Node {
  return node("header", attribs, content)
}

public func header(_ content: [Node]) -> Node {
  return header([], content)
}

public func html(_ attribs: [Attribute<Element.Html>], _ content: [Node]) -> Node {
  return node("html", attribs, content)
}

public func html(_ content: [Node]) -> Node {
  return html([], content)
}

public func img(_ attribs: [Attribute<Element.Img>]) -> Node {
  return node("img", attribs, nil)
}

public func input(_ attribs: [Attribute<Element.Input>]) -> Node {
  return node("input", attribs, nil)
}

public func label(_ attribs: [Attribute<Element.Label>], _ content: [Node]) -> Node {
  return node("label", attribs, content)
}

public func label(_ content: [Node]) -> Node {
  return label([], content)
}

public func li(_ attribs: [Attribute<Element.Li>], _ content: [Node]) -> Node {
  return node("li", attribs, content)
}

public func li(_ content: [Node]) -> Node {
  return li([], content)
}

public func main(_ attribs: [Attribute<Element.Main>], _ content: [Node]) -> Node {
  return node("main", attribs, content)
}

public func main(_ content: [Node]) -> Node {
  return main([], content)
}

public func menu(_ attribs: [Attribute<Element.Menu>], _ content: [Node]) -> Node {
  return node("menu", attribs, content)
}

public func menu(_ content: [Node]) -> Node {
  return menu([], content)
}

public func meta(_ attribs: [Attribute<Element.Meta>]) -> Node {
  return node("meta", attribs, nil)
}

public func nav(_ attribs: [Attribute<Element.Nav>], _ content: [Node]) -> Node {
  return node("nav", attribs, content)
}

public func nav(_ content: [Node]) -> Node {
  return nav([], content)
}

public func ol(_ attribs: [Attribute<Element.Ol>], _ content: [Node]) -> Node {
  return node("ol", attribs, content)
}

public func ol(_ content: [Node]) -> Node {
  return ol([], content)
}

public func p(_ attribs: [Attribute<Element.P>], _ content: [Node]) -> Node {
  return node("p", attribs, content)
}

public func p(_ content: [Node]) -> Node {
  return p([], content)
}

public func script(_ attribs: [Attribute<Element.Script>], _ script: String) -> Node {
  return node("script", attribs, [.text(EncodedString(script))])
}

public func script(_ attribs: [Attribute<Element.Script>]) -> Node {
  return node("script", attribs, [])
}

public func script(_ script: String) -> Node {
  return Html.script([], script)
}

public func source(_ attribs: [Attribute<Element.Source>]) -> Node {
  return node("source", attribs, [])
}

public func span(_ attribs: [Attribute<Element.Span>], _ content: [Node]) -> Node {
  return node("span", attribs, content)
}

public func span(_ content: [Node]) -> Node {
  return span([], content)
}

public func style(_ attribs: [Attribute<Element.Style>], _ css: String) -> Node {
  return node("style", attribs, [.text(EncodedString(css))])
}

public func style(_ css: String) -> Node {
  return style([], css)
}

public func title(_ string: String) -> Node {
  return node("title", [.text(encode(.init(string)))])
}

public func ul(_ attribs: [Attribute<Element.Ul>], _ content: [Node]) -> Node {
  return node("ul", attribs, content)
}

public func ul(_ content: [Node]) -> Node {
  return ul([], content)
}
