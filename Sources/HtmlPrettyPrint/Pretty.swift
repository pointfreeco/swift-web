import DoctorPretty
import Html
import Operadics

public func prettyPrint(node: Node, pageWidth: Int = 110) -> String {

  return (prettyPrint(node: node) as Doc)
    .renderPretty(ribbonFrac: 1, pageWidth: pageWidth)
    .displayString()
}

public func prettyPrint(nodes: [Node], pageWidth: Int = 110) -> String {

  return nodes.map(prettyPrint(node:))
    .vcat()
    .renderPretty(ribbonFrac: 1, pageWidth: pageWidth)
    .displayString()
}

private func prettyPrint(node: Node) -> Doc {
  switch node {
  case let .comment(comment):
    return prettyPrint(comment: comment)
  case let .doctype(doctype):
    return prettyPrint(doctype: doctype)
  case let .element(tag, attribs, children):
    return prettyPrint(element: tag, attribs, children)
  case let .text(text):
     return prettyPrint(text: text)
  case let .raw(text):
    return .text(text)
  }
}

private func prettyPrint(
  element tag: String,
  _ attribs: [(key: String, value: String)],
  _ children: [Node]
  )
  -> Doc {

    return prettyPrintOpenTag(element: tag, attribs, children)
      <> prettyPrintChildren(nodes: children)
      <> prettyPrintCloseTag(element: tag, children)
}


private func prettyPrintChildren(nodes: [Node]) -> Doc {
  guard !nodes.isEmpty else { return .empty }

  return nodes.map(prettyPrint(node:))
    .vcat()
    .indent(2)
}

private func prettyPrintOpenTag(
  element tag: String,
  _ attribs: [(key: String, value: String)],
  _ children: [Node]
  ) -> Doc {

  return .text("<")
    <> .text(escape(html: tag))
    <> prettyPrint(attributes: attribs)
    <> .text(">") <> (children.isEmpty ? .empty : .hardline)
}

private func prettyPrintCloseTag(
  element tag: String,
  _ children: [Node]
  )
  -> Doc {
  return children.isEmpty
    ? .empty
    : .hardline <> .text("</") <> .text(escape(html: tag)) <> .text(">")
}

private func prettyPrint(attributes attribs: [(key: String, value: String)]) -> Doc {

  return .text(attribs.count == 0 ? "" : " ")
    <> attribs
      .map(prettyPrint(attribute:))
      .sep()
      .hang(0)
}

private func prettyPrint(attribute: (key: String, value: String)) -> Doc {
  let key = escape(html: attribute.key)
  let value = escape(html: attribute.value)

  // class attributes get special rendering logic so to make them line up
  // when they flow past the page width.
  if key == "class" {
    return .text("\(key)=\"")
      <> value
        .split(separator: " ")
        .map(String.init)
        .map(Doc.text)
        .sep()
        .hang(0)
      <> .text("\"")
  }

  if key == "content" {
    return .text("\(key)=\"")
      <> value
        .split(separator: " ")
        .map(String.init)
        .map(Doc.text)
        .fillSep()
        .hang(0)
      <> .text("\"")
  }

  // style attributes also get special rendering, but aligning after the semicolon
  // that separates multiple styles
  if key == "style" {
    return .text("\(key)=\"")
      <> value
        .split(separator: ";")
        .map { Doc.text(String($0) + ";") }
        .sep()
        .hang(0)
      <> .text("\"")
  }

  return .text(key + "=\"" + value + "\"")
}

private func prettyPrint(text: String) -> Doc {
  return escape(html: text)
    .split(separator: " ")
    .map(String.init)
    .map(Doc.text)
    .fillSep()
}

private func prettyPrint(comment: String) -> Doc {
  return .text("<!--")
    <%> escape(html: comment)
      .split(separator: " ")
      .map(String.init)
      .map(Doc.text)
      .fillSep()
      .hang(0)
    <%> .text("-->")
}

private func prettyPrint(document nodes: [Node]) -> Doc {
  return nodes.map(prettyPrint(node:)).vcat()
}

private func prettyPrint(doctype: String) -> Doc {
  return .text("<!DOCTYPE")
    <%> "\(escape(html: doctype))>"
      .split(separator: " ")
      .map(String.init)
      .map(Doc.text)
      .fillSep()
}
