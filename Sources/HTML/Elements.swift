public func a(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("a", attribs, content)
}

public func a(_ content: [Node]) -> Node {
  return a([], content)
}

public func article(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("article", attribs, content)
}

public func article(_ content: [Node]) -> Node {
  return article([], content)
}

public func aside(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("aside", attribs, content)
}

public func aside(_ content: [Node]) -> Node {
  return aside([], content)
}

public func body(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("body", attribs, content)
}

public func body(_ content: [Node]) -> Node {
  return body([], content)
}

public func button(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("button", attribs, content)
}

public func button(_ content: [Node]) -> Node {
  return button([], content)
}

public func div(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("div", attribs, content)
}

public func div(_ content: [Node]) -> Node {
  return div([], content)
}

public func footer(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("footer", attribs, content)
}

public func footer(_ content: [Node]) -> Node {
  return footer([], content)
}

public func form(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("form", attribs, content)
}

public func form(_ content: [Node]) -> Node {
  return form([], content)
}

public func h1(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("h1", attribs, content)
}

public func h1(_ content: [Node]) -> Node {
  return h1([], content)
}

public func h2(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("h2", attribs, content)
}

public func h2(_ content: [Node]) -> Node {
  return h2([], content)
}

public func h3(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("h3", attribs, content)
}

public func h3(_ content: [Node]) -> Node {
  return h3([], content)
}

public func h4(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("h4", attribs, content)
}

public func h4(_ content: [Node]) -> Node {
  return h4([], content)
}

public func h5(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("h5", attribs, content)
}

public func h5(_ content: [Node]) -> Node {
  return h5([], content)
}

public func h6(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("h6", attribs, content)
}

public func h6(_ content: [Node]) -> Node {
  return h6([], content)
}

public func head(_ content: [Node]) -> Node {
  return node("head", [], content)
}

public func header(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("header", attribs, content)
}

public func header(_ content: [Node]) -> Node {
  return header([], content)
}

public func html(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("html", attribs, content)
}

public func html(_ content: [Node]) -> Node {
  return html([], content)
}

public func img(_ attribs: [Attribute]) -> Node {
  return node("img", attribs, nil)
}

public func input(_ attribs: [Attribute]) -> Node {
  return node("input", attribs, nil)
}

public func label(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("label", attribs, content)
}

public func label(_ content: [Node]) -> Node {
  return label([], content)
}

public func li(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("li", attribs, content)
}

public func li(_ content: [Node]) -> Node {
  return li([], content)
}

public func main(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("main", attribs, content)
}

public func main(_ content: [Node]) -> Node {
  return main([], content)
}

public func menu(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("menu", attribs, content)
}

public func menu(_ content: [Node]) -> Node {
  return menu([], content)
}

public func meta(_ attribs: [Attribute]) -> Node {
  return node("meta", attribs, nil)
}

public func nav(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("nav", attribs, content)
}

public func nav(_ content: [Node]) -> Node {
  return nav([], content)
}

public func ol(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("ol", attribs, content)
}

public func ol(_ content: [Node]) -> Node {
  return ol([], content)
}

public func p(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("p", attribs, content)
}

public func p(_ content: [Node]) -> Node {
  return p([], content)
}

public func script(_ attribs: [Attribute], _ script: String) -> Node {
  return node("script", attribs, [.text(EncodedString(script))])
}

public func script(_ attribs: [Attribute]) -> Node {
  return node("script", attribs, [])
}

public func script(_ script: String) -> Node {
  return Html.script([], script)
}

public func source(_ attribs: [Attribute]) -> Node {
  return node("source", attribs, [])
}

public func span(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("span", attribs, content)
}

public func span(_ content: [Node]) -> Node {
  return span([], content)
}

public func style(_ css: String) -> Node {
  return node("style", [], [.text(EncodedString(css))])
}

public func svg(_ attribs: [Attribute], _ svg: String) -> Node {
    return node("svg", attribs, [.text(EncodedString(svg))])
}

public func title(_ string: String) -> Node {
  return node("title", [], [.text(encode(.init(string)))])
}

public func ul(_ attribs: [Attribute], _ content: [Node]) -> Node {
  return node("ul", attribs, content)
}

public func ul(_ content: [Node]) -> Node {
  return ul([], content)
}
