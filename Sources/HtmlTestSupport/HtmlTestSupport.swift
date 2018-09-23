import Html
import HtmlPrettyPrint
import SnapshotTesting

extension Node: Snapshot {
  public static var snapshotPathExtension: String? {
    return "html"
  }

  public var snapshotFormat: String {
    fatalError("todo")
//    return prettyPrint(node: self)
  }
}
