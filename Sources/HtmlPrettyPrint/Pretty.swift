//import DoctorPretty
//import Html
//import Operadics
//
//public func prettyPrint(node: Node, pageWidth: Int = 110) -> String {
//
//  return (prettyPrint(node: node) as Doc)
//    .renderPretty(ribbonFrac: 1, pageWidth: pageWidth)
//    .displayString()
//}
//
//public func prettyPrint(nodes: [Node], pageWidth: Int = 110) -> String {
//
//  return nodes.map(prettyPrint(node:))
//    .vcat()
//    .renderPretty(ribbonFrac: 1, pageWidth: pageWidth)
//    .displayString()
//}
//
//private func prettyPrint(node: Node) -> Doc {
//  switch node {
//  case let .element(element):
//    return prettyPrint(element: element)
//  case let .text(text):
//    return .text(text.string)
//    // return prettyPrint(text: text)
//  case let .comment(comment):
//    return prettyPrint(comment: comment.string)
//  case let .document(nodes):
//    return prettyPrint(document: nodes)
//  }
//}
//
//private func prettyPrint(element: Element) -> Doc {
//
//  return prettyPrintOpenTag(element: element)
//    <> prettyPrintChildren(nodes: element.content)
//    <> prettyPrintCloseTag(element: element)
//}
//
//
//private func prettyPrintChildren(nodes: [Node]?) -> Doc {
//  guard let nodes = nodes else { return .empty }
//
//  return nodes.map(prettyPrint(node:))
//    .vcat()
//    .indent(2)
//}
//
//private func prettyPrintOpenTag(element: Element) -> Doc {
//
//  return .text("<")
//    <> .text(element.name)
//    <> prettyPrint(attributes: element.attribs)
//    <> .text(">") <> (element.content == nil ? .empty : .hardline)
//}
//
//private func prettyPrintCloseTag(element: Element) -> Doc {
//  return element.content == nil
//    ? .empty
//    : .hardline <> .text("</") <> .text(element.name) <> .text(">")
//}
//
//private func prettyPrint(attributes attribs: [AnyAttribute]) -> Doc {
//
//  return .text(attribs.count == 0 ? "" : " ")
//    <> attribs
//      .map(prettyPrint(attribute:))
//      .sep()
//      .hang(0)
//}
//
//private func prettyPrint(attribute: AnyAttribute) -> Doc {
//
//  // class attributes get special rendering logic so to make them line up
//  // when they flow past the page width.
//  if attribute.key == "class" {
//    return .text("\(attribute.key)=\"")
//      <> (attribute.value.renderedValue()?.string ?? "")
//        .split(separator: " ")
//        .map(String.init)
//        .map(Doc.text)
//        .sep()
//        .hang(0)
//      <> .text("\"")
//  }
//
//  if attribute.key == "content" {
//    return .text("\(attribute.key)=\"")
//      <> (attribute.value.renderedValue()?.string ?? "")
//        .split(separator: " ")
//        .map(String.init)
//        .map(Doc.text)
//        .fillSep()
//        .hang(0)
//      <> .text("\"")
//  }
//
//  // style attributes also get special rendering, but aligning after the semicolon
//  // that separates multiple styles
//  if attribute.key == "style" {
//    return .text("\(attribute.key)=\"")
//      <> (attribute.value.renderedValue()?.string ?? "")
//        .split(separator: ";")
//        .map { Doc.text(String($0) + ";") }
//        .sep()
//        .hang(0)
//      <> .text("\"")
//  }
//
//  return (attribute.value.render(with: attribute.key)?.string).map(Doc.text) ?? .zero
//}
//
//private func prettyPrint(text: EncodedString) -> Doc {
//  return text.string
//    .split(separator: " ")
//    .map(String.init)
//    .map(Doc.text)
//    .fillSep()
//}
//
//private func prettyPrint(comment: String) -> Doc {
//  return .text("<!--")
//    <%> comment
//      .split(separator: " ")
//      .map(String.init)
//      .map(Doc.text)
//      .fillSep()
//      .hang(0)
//    <%> .text("-->")
//}
//
//private func prettyPrint(document nodes: [Node]) -> Doc {
//  return .text("<!DOCTYPE html>")
//    <> .hardline
//    <> nodes.map(prettyPrint(node:)).vcat()
//}
