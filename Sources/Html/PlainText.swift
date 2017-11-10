/// Naive transformation of HTML nodes into plain text.
public func plainText(for nodes: [Node]) -> String {
  return nodes.map(plainText(for:)).joined()
}

/// Naive transformation of an HTML into plain text.
public func plainText(for node: Node) -> String {
  switch node {

  case .comment(_):
    return ""
  case let .document(document):
    return document.map(plainText).joined()
  case let .element(element):
    return plainText(for: element)
  case let .text(text):
    return text.string
  }
}

private func plainText(for element: Element) -> String {

  switch element.name.lowercased() {
  case "br":
    return "\n"
  case "style", "script":
    return ""
  case "b", "big", "i", "small", "tt", "abbr", "acronym",
       "cite", "code", "dfn", "em", "kbd", "strong", "samp",
       "var", "a", "bdo", "br", "img", "map", "object", "q",
       "script", "span", "sub", "sup", "button", "input", "label",
       "select", "textarea":
    return (element.content ?? []).map(plainText).joined()

  default:
    return (element.content ?? []).map(plainText).joined() + "\n"
  }
}
