import Html
import HtmlPrettyPrint
import Optics
import Prelude
import SnapshotTesting

extension Snapshotting where Value == [Node], Format == String {
  public static let html = SimplySnapshotting.lines
    .pullback { (nodes: [Node]) in prettyPrint(nodes) }
    |> \.pathExtension .~ "html"
}

extension Snapshotting where Value == Node, Format == String {
  public static let html = Snapshotting<[Node], String>.html.pullback { [$0] }
}
