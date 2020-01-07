import Foundation
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

  case let .element(tag, attributes, child):
    guard attributes
      .first(where: { $0.key == "style" })?
      .value?
      .range(of: "\\bdisplay:\\s*none\\b", options: .regularExpression) == nil else { return "" }
    return plainText(tag: tag, attributes: attributes, child: child)

  case let .raw(text):
    return text
    
  case let .text(text):
    return unencode(text)

  case let .fragment(children):
    return children.map(plainText(for:)).joined()
  }
}

private func plainText(tag: String, attributes: [(key: String, value: String?)], child: Node) -> String {

  switch tag.lowercased() {
  case "a":
    let content = plainText(for: child)
    let href = attributes.first(where: { $0.key == "href" })?.value

    return href.map {
      "\(content) <\($0)>"
    }
    ?? content

  case "b", "strong":
    return "**" + plainText(for: child) + "**"

  case "blockquote":
    return "> \(plainText(for: child))\n\n"

  case "br":
    return "\n"

  case "em", "i":
    return "_" + plainText(for: child) + "_"

  case "h1":
    let content = plainText(for: child)
    return """
    \(content)
    \(String(repeating: "=", count: content.count))


    """

  case "h2":
    let content = plainText(for: child)
    return """
    \(content)
    \(String(repeating: "-", count: content.count))


    """

  case "h3":
    return "### \(plainText(for: child))\n\n"
  case "h4":
    return "#### \(plainText(for: child))\n\n"
  case "h5":
    return "##### \(plainText(for: child))\n\n"
  case "h6":
    return "###### \(plainText(for: child))\n\n"

  case "head", "script", "style":
    return ""
    
  case "ol":
    return zip(1..., child.children(where: { $0.isLi }))
      .map { "  \($0). \(plainText(for: $1))" }.joined(separator: "\n") + "\n"

  case "p":
    return "\(plainText(for: child))\n\n"
    
  case "q":
    return "\"\(plainText(for: child))\""

  case "sub", "sup":
    return "[\(plainText(for: child))]"

  case "ul":
    return child
      .children(where: { $0.isLi })
      .map { "  - \(plainText(for: $0))" }.joined(separator: "\n") + "\n"

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
    return plainText(for: child)

  default:
    return plainText(for: child) + "\n"
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

fileprivate extension Node {
  func children(where isIncluded: (Node) -> Bool) -> [Node] {
    switch self {
    case let .element(_, _, node):
      return isIncluded(node) ? [node] : node.children(where: isIncluded)
    case let .fragment(nodes):
      return nodes.flatMap { isIncluded($0) ? [$0] : $0.children(where: isIncluded) }
    case .comment, .doctype, .raw, .text:
      return []
    }
  }

  var isLi: Bool {
    switch self {
    case .element("li", _, _):
      return true
    default:
      return false
    }
  }
}
