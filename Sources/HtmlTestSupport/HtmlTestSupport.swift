import Html
import HtmlPrettyPrint
import SnapshotTesting

extension Strategy {
  public static var html: Strategy<[Node], String> {
    var html = Strategy.lines.pullback { (nodes: [Node]) in
      prettyPrint(nodes)
    }
    html.pathExtension = "html"
    return html
  }

  public static var htmlNode: Strategy<Node, String> {
    return Strategy.html.pullback { [$0] }
  }
}

extension Node: DefaultDiffable {
  public static let defaultStrategy: Strategy<Node, String> = .htmlNode
}
