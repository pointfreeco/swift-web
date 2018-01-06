import Prelude

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
      .replacingOccurrences(of: "\n\n+", with: "\n\n", options: .regularExpression)
  case let .element(element):
    return plainText(for: element)
  case let .text(text):
    return unencode(text)
  }
}

private func plainText(for element: Element) -> String {

  switch element.name.lowercased() {
  case "a":
    return element.content
      .map(plainText)
      .map { desc in
        element.attribs.first(where: { $0.key == "href" })
          .flatMap { $0.value.renderedValue() }
          .flatMap(^\.string)
          .map { "\(desc) <\($0)>" }
          ?? desc
      }
      ?? ""
  case "b", "strong":
    return element.content.map(plainText).map { "**\($0)**" } ?? ""
  case "blockquote":
    return element.content.map(plainText).map { "> \($0)\n\n" } ?? ""
  case "br":
    return "\n"
  case "em", "i":
    return element.content.map(plainText).map { "_\($0)_" } ?? ""
  case "h1":
    return element.content.map(plainText)
      .map { "\($0)\n\(Array(repeatElement("=", count: $0.count)).joined())\n\n" }
      ?? ""
  case "h2":
    return element.content.map(plainText)
      .map { "\($0)\n\(Array(repeatElement("-", count: $0.count)).joined())\n\n" }
      ?? ""
  case "h3":
    return element.content.map(plainText).map { "### \($0)\n\n" } ?? ""
  case "h4":
    return element.content.map(plainText).map { "#### \($0)\n\n" } ?? ""
  case "h5":
    return element.content.map(plainText).map { "##### \($0)\n\n" } ?? ""
  case "h6":
    return element.content.map(plainText).map { "###### \($0)\n\n" } ?? ""
  case "ol":
    return element.content
      .map {
        zip(1..., $0).map { "  \($0). \(plainText(for: $1))" }.joined(separator: "\n") + "\n"
      }
      ?? ""
  case "p":
    return element.content.map(plainText).map { "\($0)\n\n" } ?? ""
  case "q":
    return element.content.map(plainText).map { "\"\($0)\"" } ?? ""
  case "sub", "sup":
    return element.content.map(plainText).map { "[\($0)]" } ?? ""
  case "script", "style":
    return ""
  case "ul":
    return element.content
      .map { $0.map { "  - \(plainText(for: $0))" }.joined(separator: "\n") + "\n" }
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
    return (element.content ?? []).map(plainText).joined()

  default:
    return (element.content ?? []).map(plainText).joined() + "\n"
  }
}
