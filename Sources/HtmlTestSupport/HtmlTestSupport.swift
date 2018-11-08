import Html
import HtmlPrettyPrint
import SnapshotTesting

extension Strategy where Snapshottable == [Node], Format == String {
  public static var html: Strategy<[Node], String> {
    var html = SimpleStrategy.lines.pullback { (nodes: [Node]) in
      prettyPrint(nodes)
    }
    html.pathExtension = "html"
    return html
  }
}

extension Strategy where Snapshottable == Node, Format == String {
  public static var htmlNode: Strategy<Node, String> {
    return Strategy<[Node], String>.html.pullback { [$0] }
  }
}

extension Node: DefaultSnapshottable {
  public static let defaultStrategy: Strategy<Node, String> = .htmlNode
}
