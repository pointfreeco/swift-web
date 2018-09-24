import Html
import HtmlPrettyPrint

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
//    let openTag = "\(indentationString)<\(tag)"
//    let tagWithAttributes = openTag + render(attribs, indentation: openTag.count + 1)
//
//    if children.isEmpty {
//      return tagWithAttributes + (voidElements.contains(tag) ? ">" : "/>") + "\n"
//    } else {
//      return tagWithAttributes + ">\n" + prettyPrint(children, indentation: indentation + 2) + "\(indentationString)</\(tag)>\n"
//    }
//
//  case let .text(string):
//    return indentationString + escapeTextNode(text: string) + "\n"
//
//  case let .raw(string):
//    return indentationString + string + "\n"
//  }
//}
//
//private func render(_ attribs: [(String, String?)], indentation: Int) -> String {
//  let indentationString = String(repeating: " ", count: indentation)
//
//  return attribs
//    .enumerated()
//    .compactMap { zip(.some($0), .some($1.0), $1.1) }
//    .map { idx, key, value in
//
//      let firstPart = (idx == 0 ? " " : "")
//        + key
//        + (value.isEmpty ? "" : "=\"")
//
//      return firstPart
//        + renderAttributeValue(key: key, value: value, indentation: firstPart.count + indentation)
//        + "\""
//    }
//    .joined(separator: "\n\(indentationString)")
//}
//
//private func renderAttributeValue(key: String, value: String, indentation: Int) -> String {
//  let parts: [String]
//  let separator: String
//  switch key {
//  case "class":
//    parts = value
//      .split(separator: " ")
//      .map(String.init)
//    separator = ""
//  case "style":
//    parts = value
//      .split(separator: ";")
//      .map(String.init)
//    separator = ";"
//  default:
//    parts = [value]
//    separator = ""
//  }
//
//  let indentationString = String(repeating: " ", count: indentation - (separator == ";" ? 2 : 1))
//
//  return parts
//    .enumerated()
//    .map { idx, part in
//      (idx == 0 ? "" : indentationString)
//        + escapeAttributeValue(part)
//    }
//    .joined(separator: "\(separator)\n")
//}
//
//private func zip<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
//  guard let a = a, let b = b, let c = c else { return nil }
//  return .some((a, b, c))
//}

func prettyPrint(_ node: Node, indentation: Int = 2, newline: String = "\n") -> String {
  let indent = { String(repeating: " ", count: indentation) }

  func renderValues(_ values: String, forKey key: String, indentBy: Int) -> String {
    switch key {
    case "class":
      return values.split(separator: " ").joined(separator: newline + String(repeating: " ", count: indentBy))
    case "style":
      return values.split(separator: ";").joined(separator: ";" + newline + String(repeating: " ", count: indentBy - 1))
    default:
      return values
    }
  }

  switch node {
  case let .comment(string):
    return indent() + "<!-- " + string + " -->" + newline
  case let .doctype(string):
    return indent() + "<!DOCTYPE " + string + ">" + newline
  case let .element(tag, attrs, children):
    let renderedAttrs = attrs.map { k, v -> String in
      let indentBy = indent().count + tag.count + k.count + 4
      return " " + k + (v.map { "=\"\(renderValues($0, forKey: k, indentBy: indentBy))\"" } ?? "")
      }.joined(separator: newline + indent() + String(repeating: " ", count: tag.count + 1))
    guard !voidElements.contains(tag) else {
      return indent() + "<" + tag + renderedAttrs + ">" + newline
    }
    return indent() + "<" + tag + renderedAttrs + ">" + newline
      + children.map { prettyPrint($0, indentation: indentation + 2, newline: newline) }.joined()
      + indent() + "</" + tag + ">" + newline
  case let .raw(string):
    return string
  case let .text(string):
    return indent() + string + newline
  }
}

let doc = html([
  body([
    p(["Hello world!"]),
    br,
    p([style("background-color: #fff; color: #f00; padding: 2rem;")], ["Goodbye!"]),
    a([href("/"), `class`("foo bar mb-x mb-y")], ["Home"]),
    footer([
      ol([`class`("list unordered mb-x mb-t")], [
        li(["Home"]),
        li(["Videos"]),
        li(["GitHub"]),
        li(["Contact Us"]),
        ])
      ])
    ])
  ])

print(prettyPrint(doc))

