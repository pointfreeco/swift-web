import Html
import Prelude

/// Naive transformation of HTML nodes into plain text.
public func plainText(for nodes: [Node]) -> String {
  return nodes.map(plainText(for:)).joined()
}

/// Naive transformation of an HTML into plain text.
public func plainText(for node: Node) -> String {
  switch node {

  case .comment, .doctype:
    return ""

  case let .element(tag, attributes, children):
    guard attributes
      .first(where: { $0.key == "style" })?
      .value?
      .range(of: "\\bdisplay:\\s*none\\b", options: .regularExpression) == nil else { return "" }
    return plainText(tag: tag, attributes: attributes, children: children)

  case let .raw(text):
    return text
  case let .text(text):
    return unencode(text)
  }
}

private func plainText(tag: String, attributes: [(key: String, value: String?)], children: [Node]) -> String {

  switch tag.lowercased() {
  case "a":
    let content = children
      .map(plainText)
      .joined()
    let href = attributes.first(where: { $0.key == "href" })?.value

    return href.map {
      "\(content) <\($0)>"
    }
    ?? content

  case "b", "strong":
    return "**" + children.map(plainText).joined() + "**"

  case "blockquote":
    return "> \(children.map(plainText).joined())\n\n"

  case "br":
    return "\n"

  case "em", "i":
    return "_" + children.map(plainText).joined() + "_"

  case "h1":
    let content = children
      .map(plainText)
      .joined()
    return """
    \(content)
    \(String(repeating: "=", count: content.count))


    """

  case "h2":
    let content = children
      .map(plainText)
      .joined()
    return """
    \(content)
    \(String(repeating: "-", count: content.count))


    """

  case "h3":
    return "### \(children.map(plainText).joined())\n\n"
  case "h4":
    return "#### \(children.map(plainText).joined())\n\n"
  case "h5":
    return "##### \(children.map(plainText).joined())\n\n"
  case "h6":
    return "###### \(children.map(plainText).joined())\n\n"

  case "head", "script", "style":
    return ""
    
  case "ol":
    return zip(1..., children)
      .map { "  \($0). \(plainText(for: $1))" }.joined(separator: "\n") + "\n"
      ?? ""

  case "p":
    return "\(children.map(plainText).joined())\n\n"
    
  case "q":
    return "\"\(children.map(plainText).joined())\""

  case "sub", "sup":
    return "[\(children.map(plainText).joined())]"

  case "ul":
    return children
      .map { "  - \(plainText(for: $0))" }.joined(separator: "\n") + "\n"
      ?? ""

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
    return children.map(plainText).joined()

  default:
    return children.map(plainText).joined() + "\n"
  }
}

private func unencode(_ encoded: String) -> String {
  return encoded
    .replacingOccurrences(of: "&amp;", with: "&")
    .replacingOccurrences(of: "&lt;", with: "<")
    .replacingOccurrences(of: "&gt;", with: ">")
    .replacingOccurrences(of: "&quot;", with: "\"")
    .replacingOccurrences(of: "&#39;", with: "'")
    .replacingOccurrences(of: "&nbsp;", with: " ")
    .replacingOccurrences(of: "&#8209;", with: "-")
}
