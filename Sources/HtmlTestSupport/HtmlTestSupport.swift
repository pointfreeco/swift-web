import Html
import HtmlPrettyPrint
import Prelude
import SnapshotTesting

extension Snapshotting where Value == [Node], Format == String {
  public static var html: Snapshotting {
    var snapshotting = SimplySnapshotting.lines
    .pullback { (nodes: [Node]) in prettyPrint(nodes) }
    snapshotting.pathExtension = "html"
    return snapshotting
  }
}

extension Snapshotting where Value == Node, Format == String {
  public static let html = Snapshotting<[Node], String>.html.pullback { [$0] }
}
