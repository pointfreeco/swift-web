import MediaType
import Prelude

public protocol ContainsList {}
public protocol ContainsOptions {}
public protocol ContainsSource {}
public protocol ContainsTrack {}

extension Element {
  public enum A: HasHref, HasRel, HasTarget {}
  public enum Abbr {}
  public enum Address {}
  public enum Area: HasAlt, HasHref, HasRel, HasTarget {}
  public enum Article {}
  public enum Aside {}
  public enum Audio: ContainsSource, ContainsTrack, HasAutoplay, HasControls, HasLoop, HasMuted, HasPreload,
    HasSrc {}
  public enum B {}
  public enum Base: HasHref, HasTarget {}
  public enum Bdi {}
  public enum Bdo {}
  public enum Blockquote: HasCite {}
  public enum Body {}
  public enum Button: HasAutofocus, HasDisabled, HasForm, HasName, HasValue {}
  public enum Canvas: HasHeight, HasWidth {}
  public enum Caption {}
  public enum Cite {}
  public enum Code {}
  public enum Col: HasSpan {}
  public enum Colgroup: HasSpan {}
  public enum Dd {}
  public enum Del: HasCite {}
  public enum Details {}
  public enum Dfn {}
  public enum Div {}
  public enum Dl {}
  public enum Dt {}
  public enum Em {}
  public enum Embed: HasHeight, HasSrc, HasMediaType, HasWidth {}
  public enum Fieldset: HasDisabled, HasForm, HasName, HasTarget {}
  public enum Figcaption {}
  public enum Figure {}
  public enum Footer {}
  public enum Form: HasName {}
  public enum H1 {}
  public enum H2 {}
  public enum H3 {}
  public enum H4 {}
  public enum H5 {}
  public enum H6 {}
  public enum Head {}
  public enum Header {}
  public enum Html {}
  public enum I {}
  public enum Iframe: HasHeight, HasName, HasSrc, HasWidth {}
  public enum Img: HasAlt, HasCrossorigin, HasHeight, HasSrc, HasSrcset, HasWidth {}
  public enum Input: HasAlt, HasAutofocus, HasDisabled, HasForm, HasHeight, HasMax, HasMaxlength, HasMin,
    HasMinlength, HasMultiple, HasName, HasPlaceholder, HasReadonly, HasRequired, HasSrc, HasValue,
    HasWidth {}
  public enum Ins: HasCite {}
  public enum Kbd {}
  public enum Keygen: HasAutofocus, HasDisabled, HasForm, HasName {}
  public enum Label: HasFor, HasForm {}
  public enum Legend {}
  public enum Li: HasValue {}
  public enum Link: HasHref, HasRel, HasMediaType {}
  public enum Main {}
  public enum Mark {}
  public enum Map: HasName {}
  public enum Meta: HasCharset {}
  public enum Meter: HasForm, HasMax, HasMin {}
  public enum Nav {}
  public enum Object: HasForm, HasHeight, HasName, HasMediaType, HasWidth {}
  public enum Ol: ContainsList {}
  public enum Optgroup: ContainsOptions, HasDisabled {}
  public enum Option: HasDisabled, HasValue {}
  public enum Output: HasFor, HasForm, HasName {}
  public enum P {}
  public enum Param: HasName, HasValue {}
  public enum Picture: ContainsSource {}
  public enum Pre {}
  public enum Progress: HasMax {}
  public enum Q: HasCite {}
  public enum S {}
  public enum Samp {}
  public enum Script: HasCharset, HasCrossorigin, HasSrc, HasMediaType {}
  public enum Section {}
  public enum Select:
    ContainsOptions, HasAutofocus, HasDisabled, HasForm, HasMultiple, HasName, HasRequired {}
  public enum Small {}
  public enum Source: HasSrc, HasSrcset, HasMediaType {}
  public enum Span {}
  public enum Strong {}
  public enum Style: HasMediaType {}
  public enum Sub {}
  public enum Summary {}
  public enum Sup {}
  public enum Table {}
  public enum Tbody {}
  public enum Td: HasColspan, HasHeaders, HasRowspan {}
  public enum Textarea: HasAutofocus, HasDisabled, HasForm, HasMaxlength, HasMinlength, HasName,
    HasPlaceholder, HasReadonly, HasRequired {}
  public enum Tfoot {}
  public enum Track: HasSrc {}
  public enum Th: HasColspan, HasHeaders, HasRowspan {}
  public enum Thead {}
  public enum Tr {}
  public enum U {}
  public enum Ul: ContainsList {}
  public enum Var {}
  public enum Video: ContainsSource, ContainsTrack, HasAutoplay, HasControls, HasHeight, HasLoop, HasMuted,
    HasPreload, HasSrc, HasWidth {}
}

public struct ChildOf<T> {
  public let node: Node

  public init(_ node: Node) {
    self.node = node
  }
}

public func a(_ attribs: [Attribute<Element.A>], _ content: [Node]) -> Node {
  return node("a", attribs, content)
}

public func a(_ content: [Node]) -> Node {
  return a([], content)
}

public func abbr(_ attribs: [Attribute<Element.Abbr>], _ content: [Node]) -> Node {
  return node("abbr", attribs, content)
}

public func abbr(_ content: [Node]) -> Node {
  return abbr([], content)
}

public func address(_ attribs: [Attribute<Element.Address>], _ content: [Node]) -> Node {
  return node("address", attribs, content)
}

public func address(_ content: [Node]) -> Node {
  return address([], content)
}

public func area(_ attribs: [Attribute<Element.Area>]) -> Node {
  return node("area", attribs, nil)
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

public func audio(_ attribs: [Attribute<Element.Audio>], _ content: [ChildOf<Element.Audio>]) -> Node {
  return node("audio", attribs, content.map(get(\.node)))
}

public func audio(_ content: [ChildOf<Element.Audio>]) -> Node {
  return audio([], content)
}

public func b(_ attribs: [Attribute<Element.B>], _ content: [Node]) -> Node {
  return node("b", attribs, content)
}

public func b(_ content: [Node]) -> Node {
  return b([], content)
}

public func base(_ attribs: [Attribute<Element.Base>]) -> ChildOf<Element.Head> {
  return .init(node("base", attribs, nil))
}

public func bdi(_ attribs: [Attribute<Element.Bdi>], _ content: [Node]) -> Node {
  return node("bdi", attribs, content)
}

public func bdi(_ content: [Node]) -> Node {
  return bdi([], content)
}

public func blockquote(_ attribs: [Attribute<Element.Blockquote>], _ content: [Node]) -> Node {
  return node("blockquote", attribs, content)
}

public func blockquote(_ content: [Node]) -> Node {
  return blockquote([], content)
}

public func body(_ attribs: [Attribute<Element.Body>], _ content: [Node]) -> ChildOf<Element.Html> {
  return .init(node("body", attribs, content))
}

public func body(_ content: [Node]) -> ChildOf<Element.Html> {
  return body([], content)
}

public let br: Node = node("br", nil)

public func button(_ attribs: [Attribute<Element.Button>], _ content: [Node]) -> Node {
  return node("button", attribs, content)
}

public func button(_ content: [Node]) -> Node {
  return button([], content)
}

public func canvas(_ attribs: [Attribute<Element.Canvas>], _ content: [Node]) -> Node {
  return node("canvas", attribs, content)
}

public func canvas(_ content: [Node]) -> Node {
  return canvas([], content)
}

public func caption(_ attribs: [Attribute<Element.Caption>], _ content: [Node]) -> Node {
  return node("caption", attribs, content)
}

public func caption(_ content: [Node]) -> Node {
  return caption([], content)
}

public func cite(_ attribs: [Attribute<Element.Cite>], _ content: [Node]) -> Node {
  return node("cite", attribs, content)
}

public func cite(_ content: [Node]) -> Node {
  return cite([], content)
}

public func code(_ attribs: [Attribute<Element.Code>], _ content: [Node]) -> Node {
  return node("code", attribs, content)
}

public func code(_ content: [Node]) -> Node {
  return code([], content)
}

public func col(_ attribs: [Attribute<Element.Col>]) -> Node {
  return node("col", attribs, nil)
}

public func colgroup(_ attribs: [Attribute<Element.Colgroup>], _ content: [Node]) -> Node {
  return node("colgroup", attribs, content)
}

public func colgroup(_ content: [Node]) -> Node {
  return colgroup([], content)
}

public func dd(_ attribs: [Attribute<Element.Dd>], _ content: [Node]) -> ChildOf<Element.Dl> {
  return .init(node("dd", attribs, content))
}

public func dd(_ content: [Node]) -> ChildOf<Element.Dl> {
  return dd([], content)
}

public func del(_ attribs: [Attribute<Element.Del>], _ content: [Node]) -> Node {
  return node("del", attribs, content)
}

public func del(_ content: [Node]) -> Node {
  return del([], content)
}

public func details(_ attribs: [Attribute<Element.Details>], _ content: [Node]) -> Node {
  return node("details", attribs, content)
}

public func details(_ content: [Node]) -> Node {
  return details([], content)
}

public func dfn(_ attribs: [Attribute<Element.Dfn>], _ content: [Node]) -> Node {
  return node("dfn", attribs, content)
}

public func dfn(_ content: [Node]) -> Node {
  return dfn([], content)
}

public func div(_ attribs: [Attribute<Element.Div>], _ content: [Node]) -> Node {
  return node("div", attribs, content)
}

public func div(_ content: [Node]) -> Node {
  return div([], content)
}

public func dl(_ attribs: [Attribute<Element.Dl>], _ content: [ChildOf<Element.Dl>]) -> Node {
  return node("dl", attribs, content.map(get(\.node)))
}

public func dl(_ content: [ChildOf<Element.Dl>]) -> Node {
  return dl([], content)
}

public func dt(_ attribs: [Attribute<Element.Dt>], _ content: [Node]) -> ChildOf<Element.Dl> {
  return .init(node("dt", attribs, content))
}

public func dt(_ content: [Node]) -> ChildOf<Element.Dl> {
  return dt([], content)
}

public func em(_ attribs: [Attribute<Element.Em>], _ content: [Node]) -> Node {
  return node("em", attribs, content)
}

public func em(_ content: [Node]) -> Node {
  return em([], content)
}

public func embed(_ attribs: [Attribute<Element.Embed>]) -> Node {
  return node("embed", attribs, nil)
}

public func fieldset(_ attribs: [Attribute<Element.Fieldset>], _ content: [Node]) -> Node {
  return node("fieldset", attribs, content)
}

public func fieldset(_ content: [Node]) -> Node {
  return fieldset([], content)
}

public func figcaption(_ attribs: [Attribute<Element.Figcaption>], _ content: [Node]) -> Node {
  return node("figcaption", attribs, content)
}

public func figcaption(_ content: [Node]) -> Node {
  return figcaption([], content)
}

public func figure(_ attribs: [Attribute<Element.Figure>], _ content: [Node]) -> Node {
  return node("figure", attribs, content)
}

public func figure(_ content: [Node]) -> Node {
  return figure([], content)
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

public func head(_ content: [ChildOf<Element.Head>]) -> ChildOf<Element.Html> {
  return .init(node("head", content.map(get(\.node))))
}

public func header(_ attribs: [Attribute<Element.Header>], _ content: [Node]) -> Node {
  return node("header", attribs, content)
}

public func header(_ content: [Node]) -> Node {
  return header([], content)
}

public let hr: Node = node("hr", nil)

public func html(_ attribs: [Attribute<Element.Html>], _ content: [ChildOf<Element.Html>]) -> Node {
  return node("html", attribs, content.map(get(\.node)))
}

public func html(_ content: [ChildOf<Element.Html>]) -> Node {
  return html([], content)
}

public func i(_ attribs: [Attribute<Element.I>], _ content: [Node]) -> Node {
  return node("i", attribs, content)
}

public func i(_ content: [Node]) -> Node {
  return i([], content)
}

public func iframe(_ attribs: [Attribute<Element.Iframe>], _ content: [Node] = []) -> Node {
  return node("iframe", attribs, content)
}

public func img(_ attribs: [Attribute<Element.Img>]) -> Node {
  return node("img", attribs, nil)
}

public func input(_ attribs: [Attribute<Element.Input>]) -> Node {
  return node("input", attribs, nil)
}

public func ins(_ attribs: [Attribute<Element.Ins>], _ content: [Node]) -> Node {
  return node("ins", attribs, content)
}

public func ins(_ content: [Node]) -> Node {
  return ins([], content)
}

public func kbd(_ attribs: [Attribute<Element.Kbd>], _ content: [Node]) -> Node {
  return node("kbd", attribs, content)
}

public func kbd(_ content: [Node]) -> Node {
  return kbd([], content)
}

public func keygen(_ attribs: [Attribute<Element.Keygen>]) -> Node {
  return node("keygen", attribs, nil)
}

public func label(_ attribs: [Attribute<Element.Label>], _ content: [Node]) -> Node {
  return node("label", attribs, content)
}

public func label(_ content: [Node]) -> Node {
  return label([], content)
}

public func legend(_ attribs: [Attribute<Element.Legend>], _ content: [Node]) -> Node {
  return node("legend", attribs, content)
}

public func legend(_ content: [Node]) -> Node {
  return legend([], content)
}

public func li<T: ContainsList>(_ attribs: [Attribute<Element.Li>], _ content: [Node]) -> ChildOf<T> {
  return .init(node("li", attribs, content))
}

public func li<T: ContainsList>(_ content: [Node]) -> ChildOf<T> {
  return li([], content)
}

public func link(_ attribs: [Attribute<Element.Link>]) -> ChildOf<Element.Head> {
  return .init(node("li", attribs, nil))
}

public func main(_ attribs: [Attribute<Element.Main>], _ content: [Node]) -> Node {
  return node("main", attribs, content)
}

public func main(_ content: [Node]) -> Node {
  return main([], content)
}

// TODO: "map" element

public func mark(_ attribs: [Attribute<Element.Mark>], _ content: [Node]) -> Node {
  return node("mark", attribs, content)
}

public func mark(_ content: [Node]) -> Node {
  return mark([], content)
}

public func meta(_ attribs: [Attribute<Element.Meta>]) -> ChildOf<Element.Head> {
  return .init(node("meta", attribs, nil))
}

public func meta(contentType: MediaType) -> ChildOf<Element.Head> {
  return meta([httpEquiv(.contentType), .init("content", contentType)])
}

public func meta(defaultStyle: String) -> ChildOf<Element.Head> {
  return meta([httpEquiv(.defaultStyle), content(defaultStyle)])
}

public func meta(refresh: Int) -> ChildOf<Element.Head> {
  return meta([httpEquiv(.refresh), .init("content", refresh)])
}

public func meta(applicationName: String) -> ChildOf<Element.Head> {
  return meta([name(.applicationName), content(applicationName)])
}

public func meta(author: String) -> ChildOf<Element.Head> {
  return meta([name(.author), content(author)])
}

public func meta(description: String) -> ChildOf<Element.Head> {
  return meta([name(.description), content(description)])
}

public func meta(generator: String) -> ChildOf<Element.Head> {
  return meta([name(.generator), content(generator)])
}

public func meta(keywords: [String]) -> ChildOf<Element.Head> {
  let keywords = keywords.map { $0.replacingOccurrences(of: ",", with: "&#44;") }.joined(separator: ",")
  return meta([name(.keywords), content(keywords)])
}

public func nav(_ attribs: [Attribute<Element.Nav>], _ content: [Node]) -> Node {
  return node("nav", attribs, content)
}

public func nav(_ content: [Node]) -> Node {
  return nav([], content)
}

public func object(_ attribs: [Attribute<Element.Object>], _ content: [Node]) -> Node {
  return node("object", attribs, content)
}

public func object(_ content: [Node]) -> Node {
  return object([], content)
}

public func ol(_ attribs: [Attribute<Element.Ol>], _ content: [ChildOf<Element.Ol>]) -> Node {
  return node("ol", attribs, content.map(get(\.node)))
}

public func ol(_ content: [ChildOf<Element.Ol>]) -> Node {
  return ol([], content)
}

public func optgroup(_ attribs: [Attribute<Element.Optgroup>], _ content: [ChildOf<Element.Optgroup>])
  -> Node {
    return node("optgroup", attribs, content.map(get(\.node)))
}

public func optgroup(_ content: [ChildOf<Element.Optgroup>]) -> Node {
  return optgroup([], content)
}

public func option<T: ContainsOptions>(_ attribs: [Attribute<Element.Option>], _ content: String)
  -> ChildOf<T> {
    return .init(node("option", attribs, [text(content)]))
}

public func option<T: ContainsOptions>(_ content: String) -> ChildOf<T> {
  return option([], content)
}

public func output(_ attribs: [Attribute<Element.Output>], _ content: [Node]) -> Node {
  return node("output", attribs, content)
}

public func output(_ content: [Node]) -> Node {
  return output([], content)
}

public func p(_ attribs: [Attribute<Element.P>], _ content: [Node]) -> Node {
  return node("p", attribs, content)
}

public func p(_ content: [Node]) -> Node {
  return p([], content)
}

public func param(_ attribs: [Attribute<Element.Param>]) -> Node {
  return node("param", attribs, nil)
}

public func picture(_ attribs: [Attribute<Element.Picture>], _ content: [ChildOf<Element.Picture>]) -> Node {
  return node("picture", attribs, content.map(get(\.node)))
}

public func picture(_ content: [ChildOf<Element.Picture>]) -> Node {
  return picture([], content)
}

public func pre(_ attribs: [Attribute<Element.Pre>], _ content: [Node]) -> Node {
  return node("pre", attribs, content)
}

public func pre(_ content: [Node]) -> Node {
  return pre([], content)
}

public func q(_ attribs: [Attribute<Element.Q>], _ content: [Node]) -> Node {
  return node("q", attribs, content)
}

public func q(_ content: [Node]) -> Node {
  return q([], content)
}

public func s(_ attribs: [Attribute<Element.S>], _ content: [Node]) -> Node {
  return node("s", attribs, content)
}

public func s(_ content: [Node]) -> Node {
  return s([], content)
}

public func samp(_ attribs: [Attribute<Element.Samp>], _ content: [Node]) -> Node {
  return node("samp", attribs, content)
}

public func samp(_ content: [Node]) -> Node {
  return samp([], content)
}

public func script(_ attribs: [Attribute<Element.Script>], _ content: String) -> Node {
  return node("script", attribs, [text(content)])
}

public func script(_ attribs: [Attribute<Element.Script>]) -> Node {
  return node("script", attribs, [])
}

public func script(_ content: String) -> Node {
  return script([], content)
}

public func script<T>(_ attribs: [Attribute<Element.Script>], _ content: String) -> ChildOf<T> {
  return .init(node("script", attribs, [text(content)]))
}

public func script<T>(_ attribs: [Attribute<Element.Script>]) -> ChildOf<T> {
  return .init(node("script", attribs, []))
}

public func script<T>(_ content: String) -> ChildOf<T> {
  return script([], content)
}

public func section(_ attribs: [Attribute<Element.Section>], _ content: [Node]) -> Node {
  return node("section", attribs, content)
}

public func section(_ content: [Node]) -> Node {
  return section([], content)
}

public func select(_ attribs: [Attribute<Element.Select>], _ content: [ChildOf<Element.Select>]) -> Node {
  return node("select", attribs, content.map(get(\.node)))
}

public func select(_ content: [ChildOf<Element.Select>]) -> Node {
  return select([], content)
}

public func small(_ attribs: [Attribute<Element.Small>], _ content: [Node]) -> Node {
  return node("small", attribs, content)
}

public func small(_ content: [Node]) -> Node {
  return small([], content)
}

public func source<T: ContainsSource>(_ attribs: [Attribute<Element.Source>]) -> ChildOf<T> {
  return .init(node("source", attribs, nil))
}

public func span(_ attribs: [Attribute<Element.Span>], _ content: [Node]) -> Node {
  return node("span", attribs, content)
}

public func span(_ content: [Node]) -> Node {
  return span([], content)
}

public func strong(_ attribs: [Attribute<Element.Strong>], _ content: [Node]) -> Node {
  return node("strong", attribs, content)
}

public func strong(_ content: [Node]) -> Node {
  return strong([], content)
}

public func style(_ attribs: [Attribute<Element.Style>], _ css: String) -> Node {
  return node("style", attribs, [text(css)])
}

public func style(_ css: String) -> Node {
  return style([], css)
}

public func style<T>(_ attribs: [Attribute<Element.Style>], _ css: String) -> ChildOf<T> {
  return .init(node("style", attribs, [text(css)]))
}

public func style<T>(_ css: String) -> ChildOf<T> {
  return style([], css)
}

public func sub(_ attribs: [Attribute<Element.Sub>], _ content: [Node]) -> Node {
  return node("sub", attribs, content)
}

public func sub(_ content: [Node]) -> Node {
  return sub([], content)
}

public func summary(_ attribs: [Attribute<Element.Summary>], _ content: [Node]) -> Node {
  return node("summary", attribs, content)
}

public func summary(_ content: [Node]) -> Node {
  return summary([], content)
}

public func sup(_ attribs: [Attribute<Element.Sup>], _ content: [Node]) -> Node {
  return node("sup", attribs, content)
}

public func sup(_ content: [Node]) -> Node {
  return sup([], content)
}

public func table(_ attribs: [Attribute<Element.Table>], _ content: [Node]) -> Node {
  return node("table", attribs, content)
}

public func table(_ content: [Node]) -> Node {
  return table([], content)
}

public func tbody(_ attribs: [Attribute<Element.Tbody>], _ content: [Node]) -> Node {
  return node("tbody", attribs, content)
}

public func tbody(_ content: [Node]) -> Node {
  return tbody([], content)
}

public func td(_ attribs: [Attribute<Element.Td>], _ content: [Node]) -> Node {
  return node("td", attribs, content)
}

public func td(_ content: [Node]) -> Node {
  return td([], content)
}

public func textarea(_ attribs: [Attribute<Element.Textarea>], _ content: String = "") -> Node {
  return node("textarea", attribs, [text(content)])
}

public func textarea(_ content: String = "") -> Node {
  return textarea([], content)
}

public func th(_ attribs: [Attribute<Element.Th>], _ content: [Node]) -> Node {
  return node("td", attribs, content)
}

public func th(_ content: [Node]) -> Node {
  return th([], content)
}

public func thead(_ attribs: [Attribute<Element.Thead>], _ content: [Node]) -> Node {
  return node("thead", attribs, content)
}

public func thead(_ content: [Node]) -> Node {
  return thead([], content)
}

public func title(_ string: String) -> ChildOf<Element.Head> {
  return .init(node("title", [text(string)]))
}

public func tr(_ attribs: [Attribute<Element.Tr>], _ content: [Node]) -> Node {
  return node("tr", attribs, content)
}

public func tr(_ content: [Node]) -> Node {
  return tr([], content)
}

public func track<T: ContainsTrack>(_ attribs: [Attribute<Element.Track>]) -> ChildOf<T> {
  return .init(node("track", attribs, nil))
}

public func u(_ attribs: [Attribute<Element.U>], _ content: [Node]) -> Node {
  return node("u", attribs, content)
}

public func u(_ content: [Node]) -> Node {
  return u([], content)
}

public func ul(_ attribs: [Attribute<Element.Ul>], _ content: [ChildOf<Element.Ul>]) -> Node {
  return node("ul", attribs, content.map(get(\.node)))
}

public func ul(_ content: [ChildOf<Element.Ul>]) -> Node {
  return ul([], content)
}

public func `var`(_ attribs: [Attribute<Element.Var>], _ content: [Node]) -> Node {
  return node("var", attribs, content)
}

public func `var`(_ content: [Node]) -> Node {
  return `var`([], content)
}

public func video(_ attribs: [Attribute<Element.Video>], _ content: [ChildOf<Element.Video>]) -> Node {
  return node("video", attribs, content.map(get(\.node)))
}

public func video(_ content: [ChildOf<Element.Video>]) -> Node {
  return video([], content)
}

public let wbr: Node = node("wbr", nil)
