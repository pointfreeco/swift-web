import Prelude
import Either

public func render(config: Config = .pretty, css: Stylesheet) -> String {
  return render(config: config, [], css)
}

func render(config: Config, _ sel: [App], _ css: Stylesheet) -> String {
  return renderRules(config, sel, runS(css))
}

func render(attrModifier: CssSelector.Attribute.Modifier) -> String {
  switch attrModifier {
  case .val:      return ""
  case .begins:   return "^"
  case .ends:     return "$"
  case .contains: return "*"
  case .space:    return "~"
  case .hyphen:   return "|"
  }
}

func render(attribute: CssSelector.Attribute) -> String {
  switch attribute {
  case let .match(key, modifier, value):
    return key + render(attrModifier: modifier) + "=\"" + value + "\""
  case let .exists(value):
    return value
  }
}

public func renderSelector(_ selector: CssSelector) -> String {
  switch selector {
  case .star:
    return "*"
  case let .elem(elem):
    return render(element: elem)
  case let .id(str):
    return "#" + str
  case let .`class`(str):
    return "." + str
  case let .pseudo(pseudoClass):
    return ":" + render(pseudoClass: pseudoClass)
  case let .pseudoElem(pseudoElem):
    return "::" + render(pseudoElem: pseudoElem)
  case let .attr(sel, attr):
    return renderSelector(sel) + "[" + render(attribute: attr) + "]"
  case let .child(l, r):
    return renderSelector(l) + " > " + renderSelector(r)
  case let .sibling(l, r):
    return renderSelector(l) + " ~ " + renderSelector(r)
  case let .deep(l, r):
    return renderSelector(l) + " " + renderSelector(r)
  case let .adjacent(l, r):
    return renderSelector(l) + " + " + renderSelector(r)
  case let .combined(l, r):
    return renderSelector(l) + renderSelector(r)
  case let .union(l, r):
    return renderSelector(l) + ", " + renderSelector(r)
  }
}

func render(pseudoClass: CssSelector.PseudoClass) -> String {
  switch pseudoClass {
  case .active:
    return "active"
  case .checked:
    return "checked"
  case .disabled:
    return "disabled"
  case .empty:
    return "empty"
  case .enabled:
    return "enabled"
  case .firstChild:
    return "first-child"
  case .firstOfType:
    return "first-of-type"
  case .focus:
    return "focus"
  case .hover:
    return "hover"
  case .inRange:
    return "in-range"
  case .invalid:
    return "invalid"
  case let .lang(str):
    return "lang(" + str + ")"
  case .lastChild:
    return "last-child"
  case .lastOfType:
    return "last-of-type"
  case .link:
    return "link"
  case let .not(sel):
    return "not(" + renderSelector(sel) + ")"
  case let .nthChild(n):
    return "nth-child(\(n))"
  case let .nthLastChild(n):
    return "nth-last-child(\(n))"
  case let .nthLastOfType(n):
    return "nth-last-of-type(\(n))"
  case let .nthOfType(n):
    return "nth-of-type(\(n))"
  case .onlyOfType:
    return "only-of-type"
  case .onlyChild:
    return "only-chid"
  case .optional:
    return "optional"
  case .outOfRange:
    return "out-of-range"
  case .readOnly:
    return "read-only"
  case .readWrite:
    return "read-write"
  case .required:
    return "required"
  case .root:
    return "root"
  case .target:
    return "target"
  case .valid:
    return "valid"
  case .visited:
    return "visited"
  }
}

func render(pseudoElem: CssSelector.PseudoElem) -> String {
  switch pseudoElem {
  case .after:
    return "after"
  case .before:
    return "before"
  case .firstLetter:
    return "first-letter"
  case .firstSentence:
    return "first-sentence"
  case .selection:
    return "selection"
  }
}

func render(element: CssSelector.Element) -> String {
  switch element {
  case .a:
    return "a"
  case .abbr:
    return "abbr"
  case .address:
    return "address"
  case .aside:
    return "aside"
  case .article:
    return "article"
  case .audio:
    return "audio"
  case .b:
    return "b"
  case .blockquote:
    return "blockquote"
  case .body:
    return "body"
  case .canvas:
    return "canvas"
  case .caption:
    return "caption"
  case .cite:
    return "cite"
  case .code:
    return "code"
  case .dd:
    return "dd"
  case .details:
    return "details"
  case .div:
    return "div"
  case .dl:
    return "dl"
  case .dt:
    return "dt"
  case .em:
    return "em"
  case .embed:
    return "embed"
  case .fieldset:
    return "fieldset"
  case .figure:
    return "figure"
  case .figcaption:
    return "figcaption"
  case .form:
    return "form"
  case .footer:
    return "footer"
  case .h1:
    return "h1"
  case .h2:
    return "h2"
  case .h3:
    return "h3"
  case .h4:
    return "h4"
  case .h5:
    return "h5"
  case .h6:
    return "h6"
  case .hgroup:
    return "hgroup"
  case .header:
    return "header"
  case .html:
    return "html"
  case .i:
    return "i"
  case .iframe:
    return "iframe"
  case .img:
    return "img"
  case .input:
    return "input"
  case .label:
    return "label"
  case .legend:
    return "legend"
  case .li:
    return "li"
  case .menu:
    return "menu"
  case .nav:
    return "nav"
  case .ol:
    return "ol"
  case let .other(str):
    return str
  case .p:
    return "p"
  case .pre:
    return "pre"
  case .q:
    return "q"
  case .section:
    return "section"
  case .span:
    return "span"
  case .strong:
    return "strong"
  case .summary:
    return "summary"
  case .table:
    return "table"
  case .tbody:
    return "tbody"
  case .td:
    return "td"
  case .tfoot:
    return "tfoot"
  case .th:
    return "th"
  case .thead:
    return "thead"
  case .time:
    return "time"
  case .tr:
    return "tr"
  case .u:
    return "u"
  case .ul:
    return "ul"
  case .video:
    return "video"
  }
}

func imp(_ config: Config) -> (String) -> String {
  return { str in "@import url(" + str + ";" + config.newline }
}

func properties(_ config: Config, _ xs: [Either<String, (String, String)>]) -> String {

  let width = 1 + (rights(xs).map(first >>> ^\.count).max() ?? 0)
  let ind = config.indentation
  let new = config.newline
  let finalSemi = config.finalSemicolon ? ";" : ""

  func helper(_ p: Either<String, (String, String)>) -> String {
    switch p {
    case let .left(w):
      return config.warn
        ? ind + "/* no value for " + w + " */" + new
        : ""
    case let .right(pair):
      let (k, v) = pair
      let pad = config.align
        ? replicate(width - k.count)(" ")
        : ""
      return ind + k + pad + ":" + config.sep + v
    }
  }

  let tmp1 = xs.map(helper)
  let tmp2 = tmp1.joined(separator: ";" + new)
  return tmp2 + finalSemi + new
}


func collect(_ key: Key<Unit>, _ value: Value) -> [Either<String, (String, String)>] {

  switch (key.unKeys, value.unValue) {
  case let (.plain(k), .plain(v)):
    return [.right((k, v))]
  case let (.prefixed(ks), .plain(v)):
    return ks.map { pk in
      let (p, k) = pk
      return .right((p <> k, v))
    }
  case let (.plain(k), .prefixed(vs)):
    return vs.map { pv in
      let (p, v) = pv
      return .right((k, p <> v))
    }
  case let (.prefixed(ks), .prefixed(vs)):
    return ks.map { pk in
      let (p, k) = pk
      let v = lookup(p)(vs)
      return v.map { .right((p + k, $0 + p)) } ?? .left(p + k)
    }
  }
}

func merger(_ xs: [App]) -> CssSelector {
  guard let (head, tail) = uncons(xs) else {
    // todo: is this the right default?
    return .elem(.other(""))
  }

  switch head {
  case let .`self`(f):
    return tail.isEmpty
      ? f
      : CssSelector.combined(merger(tail), f)
  case let .root(s):
    return .deep(s, merger(tail))
  case let .pop(i):
    return merger(Array(tail.dropFirst(i)))
  case let .child(s):
    return tail.isEmpty
      ? s
      : .child(merger(tail), s)
  case let .sub(s):
    return tail.isEmpty
      ? s
      : .deep(merger(tail), s)
  }
}

public func renderRule(_ config: Config, _ sel: [App], _ props: [(Key<Unit>, Value)]) -> String {

  guard !props.isEmpty else { return "" }

  let xs = props.flatMap { collect($0.0, $0.1) }

  return renderSelector(merger(sel))
    + config.sep
    + config.lbrace
    + config.newline
    + properties(config, xs)
    + config.rbrace
    + config.newline
}

func renderRules(_ config: Config, _ sel: [App], _ rs: [Rule]) -> String {

  let _property = renderRule(config, sel, rs.compactMap { $0.property })
  let _import = foldMap(imp(config))(rs.compactMap { $0.`import` })
  let _face = foldMap(face(config))(rs.compactMap { $0.face })
  let _nested = foldMap({ ab in renderRules(config, [ab.0] + sel, ab.1)})(rs.compactMap { $0.nested })

  let _query = foldMap({ ab in query(config, ab.0, sel, ab.1)})(rs.compactMap({ $0.query }))

  return _property
    + config.newline
    + _import
    // keyframes
    + _face
    + _nested
    + _query
}

func face(_ config: Config) -> ([Rule]) -> String {
  return { rs in "@font-face" + renderRules(config, [], rs) }
}

func query(_ config: Config, _ query: MediaQuery, _ sel: [App], _ rs: [Rule]) -> String {
  return mediaQuery(query)
    + config.sep
    + config.lbrace
    + config.newline
    + renderRules(config, sel, rs)
    + config.rbrace
    + config.newline
}

func mediaQuery(_ query: MediaQuery) -> String {

  func notOrOnly(_ notOrOnly: NotOrOnly?) -> String {
    switch notOrOnly {
    case .none: return ""
    case .some(.not): return "not "
    case .some(.only): return "only "
    }
  }

  return "@media "
    + notOrOnly(query.notOrOnly)
    + mediaType(query.mediaType)
    + (query.features.isEmpty ? "" : " and ")
    + query.features.map(render(feature:)).joined(separator: " and ")
}

func mediaType(_ type: MediaType) -> String {
  return plain(type.mediaType.unValue)
}

func render(feature: Feature) -> String {
  switch feature.value {
  case .none:
    return feature.key
  case let .some(v):
    return "(" + feature.key + ": " + plain(v.unValue) + ")"
  }
}
