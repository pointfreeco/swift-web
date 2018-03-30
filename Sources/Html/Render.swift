import Prelude

public struct Config {
  let indentation: String
  let newline: String
}

public let compact = Config(indentation: "", newline: "")
public let pretty  = Config(indentation: "  ", newline: "\n")

public func render(_ nodes: [Node]) -> String {
  return render(nodes, config: compact)
}

public func render(_ nodes: [Node], config: Config) -> String {
  return nodes |> foldMap { render($0, config: config) }
}

public func render(_ node: Node) -> String {
  return render(node, config: compact)
}

public func render(_ node: Node, config: Config = compact) -> String {

  func realRender(_ node: Node, config: Config, indentation: String) -> String {

    switch node {
    case let .comment(string):
      return indentation + "<!-- " + string.string + " -->" + config.newline
    case let .document(nodes):
      return indentation + "<!DOCTYPE html>" + config.newline + nodes
        .map { realRender($0, config: config, indentation: indentation) }
        .joined(separator: config.newline)
    case let .element(element):
      let _attribs = element.attribs
        .map { attrib in attrib.value.render(with: attrib.key)?.string }
        .compactMap { $0 }
        .joined(separator: " ")
      let attribs = _attribs.isEmpty ? "" : " " + _attribs

      let renderedChildren = element.content
        .map {
          $0.map {
            realRender(
              $0,
              config: config,
              indentation: indentation + config.indentation
            )
          }
        }?.joined()

      return renderedChildren
        .map { children -> String in
          indentation + "<\(element.name)\(attribs)>"
            + config.newline
            + children
            + indentation + "</\(element.name)>"
            + config.newline
        }
        ?? "\(indentation)<\(element.name)\(attribs)>\(config.newline)"

    case let .text(string):
      return indentation + string.string + config.newline
    }
  }

  return realRender(node, config: config, indentation: "")
}
