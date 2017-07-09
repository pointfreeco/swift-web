import Html
import HtmlPrettyPrint
import SnapshotAssertion

extension Node: Snapshot {
  public var snapshotFormat: String {
    return prettyPrint(node: self)
  }
}
