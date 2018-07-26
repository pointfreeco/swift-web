import Prelude

public struct Config {
  let indentation: String
  let newline: String

  public static let compact = Config(indentation: "", newline: "")
  public static let pretty  = Config(indentation: "  ", newline: "\n")
}

public func render(_ nodes: [Node], config: Config = .compact) -> String {
  return nodes |> foldMap { render($0, config: config) }
}

public func render(_ node: Node, config: Config = .compact) -> String {
  func realRender(_ node: Node, config: Config, indentation: String) -> String {
    switch node {
    case let .comment(string):
      return indentation + "<!-- " + escape(html: string) + " -->" + config.newline
    case let .doctype(string):
      return indentation + "<!DOCTYPE " + escape(html: string) + ">" + config.newline
    case let .element(tag, attribs, children):
      let tag = escape(html: tag)

      let attribs = attribs.isEmpty ? "" : " " + attribs
        .map { key, value in
          value.isEmpty
            ? escape(html: key)
            : escape(html: key) + "=\"" + escape(html: value) + "\""
        }
        .joined(separator: " ")

      let close = voidElements.contains(tag) ? ">" : "/>"

      guard !children.isEmpty else { return indentation + "<" + tag + attribs + close + config.newline }

      let children = children
        .map {
          realRender(
            $0,
            config: tag == "pre" ? .compact : config,
            indentation: tag == "pre" ? "" : indentation + config.indentation
          )
        }
        .joined()

      return indentation + "<" + tag + attribs + ">" + config.newline
        + children
        + indentation + "</" + tag + ">" + config.newline

    case let .text(string):
      return indentation + escape(html: string) + config.newline
    case let .raw(string):
      return string
    }
  }

  return realRender(node, config: config, indentation: "")
}

public func escape(html: String) -> String {
  return html
    .replacingOccurrences(of: "&", with: "&amp;")
    .replacingOccurrences(of: "<", with: "&lt;")
    .replacingOccurrences(of: ">", with: "&gt;")
    .replacingOccurrences(of: "\"", with: "&quot;")
    .replacingOccurrences(of: "'", with: "&#39;")
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
