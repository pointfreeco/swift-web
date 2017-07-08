import DoctorPretty
import Operadics
import Html

public func prettyPrint(
  node: Node,
  pageWidth: Int = 110
  ) -> String {

  return (prettyPrint(node: node) as Doc)
    .renderPretty(ribbonFrac: 1, pageWidth: pageWidth)
    .displayString()
}

private func prettyPrint(node: Node) -> Doc {
  switch node {
  case let .element(element):
    return prettyPrint(element: element)
  case let .text(text):
    return .text(text.string)
  case let .comment(comment):
    return prettyPrint(comment: comment)
  case let .document(nodes):
    return prettyPrint(document: nodes)
  }
}

private func prettyPrint(element: Element) -> Doc {

  return prettyPrintOpenTag(element: element)
    <> (element.content ?? [])
      .map(prettyPrint(node:))
      .vcat()
      .indent(2)
    <> .hardline
    <> prettyPrintCloseTag(element: element)
}

private func prettyPrintOpenTag(element: Element) -> Doc {

  return .text("<")
    <> .text(element.name)
    <> prettyPrint(attributes: element.attribs)
    <> .text(">")
    <> .hardline
}

private func prettyPrintCloseTag(element: Element) -> Doc {
  return .text("</")
    <> .text(element.name)
    <> .text(">")
}

private func prettyPrint(attributes attribs: [Attribute]) -> Doc {

  return (attribs.count == 0 ? .text("") : .text(" "))
    <%%> attribs
      .map(prettyPrint(attribute:))
      .fillSep()
      .hang(0)
}

private func prettyPrint(attribute: Attribute) -> Doc {
  return .text(attribute.value.render(with: attribute.key)?.string ?? "")
}

private func prettyPrint(comment: String) -> Doc {
  return Doc.text("<!--")
    <%> comment
      .split(separator: " ")
      .map(String.init)
      .map(Doc.text)
      .fillSep()
      .hang(0)
    <%> Doc.text("-->")
}

private func prettyPrint(document nodes: [Node]) -> Doc {
  return Doc.text("<!DOCTYPE html>")
    <> .hardline
    <> nodes.map(prettyPrint(node:)).vcat()
}

