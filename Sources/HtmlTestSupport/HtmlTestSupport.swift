import Html
import HtmlPrettyPrint
import SnapshotAssertion

extension Node: Snapshot {
  public static var snapshotFileExtension: String? {
    return "html"
  }

  public var snapshotFormat: String {
    return prettyPrint(node: self)
  }
}
