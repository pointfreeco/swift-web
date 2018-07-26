import Prelude

/// Naive transformation of HTML nodes into plain text.
public func plainText(for nodes: [Node]) -> String {
  return nodes.map(plainText(for:))
    .joined()
    .replacingOccurrences(of: "\n\n+", with: "\n\n", options: .regularExpression)
}

/// Naive transformation of an HTML into plain text.
public func plainText(for node: Node) -> String {
  switch node {
  case .comment, .doctype, .raw:
    return ""
  case let .element(tag, attribs, children):
    guard attribs
      .first(where: { $0.key == "style" })?
      .value
      .range(of: "\\bdisplay:\\s*none\\b", options: .regularExpression) == nil else { return "" }

    return plainText(for: tag, attribs, children)
  case let .text(text):
    return text
  }
}

private func plainText(
  for tag: String,
  _ attribs: [(key: String, value: String)],
  _ children: [Node]
  )
  -> String {

    switch tag.lowercased() {
    case "a":
      let text = plainText(for: children)
      guard let href = attribs.first(where: { $0.key == "href" }).map({ $0.value }) else { return text }
      return text + " <" + href + ">"
    case "b", "strong":
      return "**" + plainText(for: children) + "**"
    case "blockquote":
      return "> " + plainText(for: children) + "\n\n"
    case "br":
      return "\n"
    case "em", "i":
      return "_" + plainText(for: children) + "_"
    case "h1":
      let title = plainText(for: children)
      return title + "\n" + Array(repeatElement("=", count: title.count)).joined() + "\n\n"
    case "h2":
      let title = plainText(for: children)
      return title + "\n" + Array(repeatElement("-", count: title.count)).joined() + "\n\n"
    case "h3":
      return "### " + plainText(for: children) + "\n\n"
    case "h4":
      return "#### " + plainText(for: children) + "\n\n"
    case "h5":
      return "##### " + plainText(for: children) + "\n\n"
    case "h6":
      return "###### " + plainText(for: children) + "\n\n"
    case "head", "script", "style":
      return ""
    case "ol":
      return zip(1..., children)
        .map { "  \($0). \(plainText(for: $1))" }.joined(separator: "\n") + "\n"
    case "p":
      return plainText(for: children) + "\n\n"
    case "q":
      return "\"" + plainText(for: children) + "\""
    case "sub", "sup":
      return "[" + plainText(for: children) + "]"
    case "ul":
      return children.map { "  - \(plainText(for: $0))" }.joined(separator: "\n") + "\n"
    case "abbr",
         "acronym",
         "bdo",
         "big",
         "button",
         "cite",
         "code",
         "dfn",
         "img",
         "input",
         "kbd",
         "label",
         "map",
         "object",
         "samp",
         "select",
         "small",
         "span",
         "textarea",
         "tt",
         "var":
      return plainText(for: children)

    default:
      return plainText(for: children) + "\n"
    }
}
