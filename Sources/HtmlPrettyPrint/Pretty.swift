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
  case let .element(tag, attrs, children):
    return prettyPrint(tag: tag, attrs: attrs, children: children)
  case let .text(text):
    return prettyPrint(text: escapeTextNode(text: text))
  case let .raw(text):
    return prettyPrint(text: text)
  case let .comment(comment):
    return prettyPrint(comment: comment)
  case let .doctype(doctype):
    return prettyPrint(doctype: doctype)
  }
}

private func prettyPrint(tag: String, attrs: [(String, String?)], children: [Node]) -> Doc {

  return prettyPrintOpenTag(tag, attrs: attrs, children: children)
    <> prettyPrintChildren(nodes: children)
    <> prettyPrintCloseTag(tag)
}


private func prettyPrintChildren(nodes: [Node]) -> Doc {
  return nodes.map(prettyPrint(node:))
    .vcat()
    .indent(2)
}

private func prettyPrintOpenTag(_ tag: String, attrs: [(String, String?)], children: [Node]) -> Doc {

  return .text("<")
    <> .text(tag)
    <> prettyPrint(attrs: attrs)
    <> .text(">") <> (children.isEmpty ? .empty : .hardline)
}

private func prettyPrintCloseTag(_ tag: String) -> Doc {
  return voidElements.contains(tag)
    ? .empty
    : .hardline <> .text("</") <> .text(tag) <> .text(">")
}

private func prettyPrint(attrs: [(String, String?)]) -> Doc {

  return .text(attrs.count == 0 ? "" : " ")
    <> attrs
      .map(prettyPrint(attr:))
      .sep()
      .hang(0)
}

private func prettyPrint(attr: (String, String?)) -> Doc {
  let (key, value) = attr

  // class attributes get special rendering logic so to make them line up
  // when they flow past the page width.
  if key == "class" {
    return .text("\(key)=\"")
      <> (value ?? "")
        .split(separator: " ")
        .map(String.init)
        .map(Doc.text)
        .sep()
        .hang(0)
      <> .text("\"")
  }

  if key == "content" {
    return .text("\(key)=\"")
      <> (value ?? "")
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
      <> (value ?? "")
        .split(separator: ";")
        .map { Doc.text(String($0) + ";") }
        .sep()
        .hang(0)
      <> .text("\"")
  }

  return value
    .map { value in
      value.isEmpty
        ? key
        : key + "=\"" + escapeAttributeValue(value) + "\""
    }
    .map(Doc.text)
    ?? .zero
}

private func prettyPrint(text: String) -> Doc {
  return text
    .split(separator: " ")
    .map(String.init)
    .map(Doc.text)
    .fillSep()
}

private func prettyPrint(comment: String) -> Doc {
  return .text("<!--")
    <%> comment
      .split(separator: " ")
      .map(String.init)
      .map(Doc.text)
      .fillSep()
      .hang(0)
    <%> .text("-->")
}

private func prettyPrint(document nodes: [Node]) -> Doc {
  return .text("<!DOCTYPE html>")
    <> .hardline
    <> nodes.map(prettyPrint(node:)).vcat()
}

private func prettyPrint(doctype: String) -> Doc {
  return .text("<!DOCTYPE " +  doctype + ">")
}

private let voidElements: Set<String> = [
  "area",
  "base",
  "br",
  "col",
  "embed",
  "hr",
  "img",
  "input",
  "link",
  "meta",
  "param",
  "source",
  "track",
  "wbr"
]
