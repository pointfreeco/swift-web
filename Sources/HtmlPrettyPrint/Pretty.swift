//import Html
//
///// Renders an array of nodes to an HTML string.
/////
///// - Parameter nodes: An array of nodes.
//public func prettyPrint(_ nodes: [Node]) -> String {
//  return nodes.map(prettyPrint).joined()
//}
//
///// Renders a node to an HTML string.
/////
///// - Parameter node: A node.
//public func prettyPrint(_ node: Node) -> String {
//  return prettyPrint(node, indentation: 0)
//}
//
//public func render<T>(_ children: [ChildOf<T>]) -> String {
//  return children.map(prettyPrint).joined()
//}
//
//public func prettyPrint<T>(_ child: ChildOf<T>) -> String {
//  return prettyPrint(child.rawValue)
//}
//
//private func prettyPrint(_ nodes: [Node], indentation: Int) -> String {
//  return nodes.map { prettyPrint($0, indentation: indentation) }.joined()
//}
//
//private func prettyPrint(_ node: Node, indentation: Int) -> String {
//  let indentationString = String(repeating: " ", count: indentation)
//
//  switch node {
//  case let .comment(string):
//    return "\(indentationString)<!-- \(string.replacingOccurrences(of: "-->", with: "--&gt;")) -->\n"
//
//  case let .doctype(string):
//    return "\(indentationString)<!DOCTYPE \(string.replacingOccurrences(of: ">", with: "&gt;"))>\n"
//
//  case let .element(tag, attribs, children):
//
//    let tag = "\(indentationString)<\(tag) "
//    let tagWithAttributes = tag + render(attribs, indentation: tag.count + indentation)
//
//    if children.isEmpty {
//      return tagWithAttributes + (voidElements.contains(tag) ? ">" : "/>") + "\n"
//    } else {
//      return tagWithAttributes + ">\n" + prettyPrint(children, indentation: indentation + 2) + "\(indentation)</\(tag)>\n"
//    }
//
////    let renderedAttribs = render(attribs)
////    guard !children.isEmpty else {
////      return "\(indentationString)<" + tag + renderedAttribs + (voidElements.contains(tag) ? ">" : "/>")
////    }
////    return "\(indentationString)<" + tag + renderedAttribs + ">" + render(children) + "</" + tag + ">"
//
//  case let .text(string):
//    return indentationString + escapeTextNode(text: string)
//
//  case let .raw(string):
//    return indentationString + string
//  }
//}
//
//private func render(_ attribs: [(String, String?)], indentation: Int) -> String {
//  let indentationString = String(repeating: " ", count: indentation)
//
//  let tmp = attribs
//    .enumerated()
//    .compactMap { zip(.some($0), .some($1.0), $1.1) }
//    .map { idx, key, value in
//      (idx == 0 ? "" : indentationString)
//        + key
//        + (value.isEmpty ? "" : "=\"\(escapeAttributeValue(value))\"")
//    }
//    .joined(separator: "\n\(indentationString)")
//
//  return tmp
//
////  return attribs
////    .compactMap { key, value in
////      value.map {
////        " " + key + ($0.isEmpty ? "" : "=\"\(escapeAttributeValue($0))\"")
////      }
////    }
////    .joined()
//}
//
//private func zip<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
//  guard let a = a, let b = b, let c = c else { return nil }
//  return .some((a, b, c))
//}


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
//  case let .element(tag, attrs, children):
//    return prettyPrint(tag: tag, attrs: attrs, children: children)
//  case let .text(text):
//    return prettyPrint(text: escapeTextNode(text: text))
//  case let .raw(text):
//    return prettyPrint(text: text)
//  case let .comment(comment):
//    return prettyPrint(comment: comment)
//  case let .doctype(doctype):
//    return prettyPrint(doctype: doctype)
//  }
//}
//
//private func prettyPrint(tag: String, attrs: [(String, String?)], children: [Node]) -> Doc {
//
//  return prettyPrintOpenTag(tag, attrs: attrs, children: children)
//    <> prettyPrintChildren(nodes: children)
//    <> prettyPrintCloseTag(tag)
//}
//
//
//private func prettyPrintChildren(nodes: [Node]) -> Doc {
//  return nodes.map(prettyPrint(node:))
//    .vcat()
//    .indent(2)
//}
//
//private func prettyPrintOpenTag(_ tag: String, attrs: [(String, String?)], children: [Node]) -> Doc {
//
//  return .text("<")
//    <> .text(tag)
//    <> prettyPrint(attrs: attrs)
//    <> .text(">") <> (children.isEmpty ? .empty : .hardline)
//}
//
//private func prettyPrintCloseTag(_ tag: String) -> Doc {
//  return voidElements.contains(tag)
//    ? .empty
//    : .hardline <> .text("</") <> .text(tag) <> .text(">")
//}
//
//private func prettyPrint(attrs: [(String, String?)]) -> Doc {
//
//  return .text(attrs.count == 0 ? "" : " ")
//    <> attrs
//      .map(prettyPrint(attr:))
//      .sep()
//      .hang(0)
//}
//
//private func prettyPrint(attr: (String, String?)) -> Doc {
//  let (key, value) = attr
//
//  // class attributes get special rendering logic so to make them line up
//  // when they flow past the page width.
//  if key == "class" {
//    return .text("\(key)=\"")
//      <> (value ?? "")
//        .split(separator: " ")
//        .map(String.init)
//        .map(Doc.text)
//        .sep()
//        .hang(0)
//      <> .text("\"")
//  }
//
//  if key == "content" {
//    return .text("\(key)=\"")
//      <> (value ?? "")
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
//  if key == "style" {
//    return .text("\(key)=\"")
//      <> (value ?? "")
//        .split(separator: ";")
//        .map { Doc.text(String($0) + ";") }
//        .sep()
//        .hang(0)
//      <> .text("\"")
//  }
//
//  return value
//    .map { value in
//      value.isEmpty
//        ? key
//        : key + "=\"" + escapeAttributeValue(value) + "\""
//    }
//    .map(Doc.text)
//    ?? .zero
//}
//
//private func prettyPrint(text: String) -> Doc {
//  return text
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
//
//private func prettyPrint(doctype: String) -> Doc {
//  return .text("<!DOCTYPE " +  doctype + ">")
//}
//
//private let voidElements: Set<String> = [
//  "area",
//  "base",
//  "br",
//  "col",
//  "embed",
//  "hr",
//  "img",
//  "input",
//  "link",
//  "meta",
//  "param",
//  "source",
//  "track",
//  "wbr"
//]
