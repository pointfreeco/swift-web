import Html

public func prettyPrint(_ nodes: [Node], indentation: Int = 2, newline: String = "\n") -> String {
  return nodes
    .map { prettyPrint($0, indentation: indentation, newline: newline) }
    .joined(separator: "\n")
}

public func prettyPrint(_ node: Node, indentation: Int = 2, newline: String = "\n") -> String {
  let indent = { String(repeating: " ", count: indentation) }

  func renderValues(_ values: String, separator: Character, indentBy: Int) -> String {
    return values
      .split(separator: separator)
      .joined(separator: (separator == " " ? "" : String(separator)) + newline + String(repeating: " ", count: indentBy + (separator == " " ? 1 : 0)))
  }

  func separator(forKey key: String) -> Character {
    switch key {
    case "class":
      return " "
    case "style":
      return ";"
    default:
      return " "
    }
  }

  switch node {
  case let .comment(string):
    return indent() + "<!-- " + string + " -->" + newline
  case let .doctype(string):
    return indent() + "<!DOCTYPE " + string + ">" + newline
  case let .element(tag, attrs, children):
    let renderedAttrs = attrs.map { k, v -> String in
      let indentBy = indent().count + tag.count + k.count + 3
      return " " + k + (v.map { "=\"\(renderValues($0, separator: separator(forKey: k), indentBy: indentBy))\"" } ?? "")
      }.joined(separator: newline + indent() + String(repeating: " ", count: tag.count + 1))
    guard !voidElements.contains(tag) else {
      return indent() + "<" + tag + renderedAttrs + ">" + newline
    }
    return indent() + "<" + tag + renderedAttrs + ">" + newline
      + children.map { prettyPrint($0, indentation: indentation + 2, newline: newline) }.joined()
      + indent() + "</" + tag + ">" + newline
  case let .raw(string):
    return indent() + string + newline
  case let .text(string):
    return indent() + string + newline
  }
}
