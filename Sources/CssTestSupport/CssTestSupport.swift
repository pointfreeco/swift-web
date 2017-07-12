import Css
import SnapshotTesting

extension Stylesheet: Snapshot {
  public static var snapshotFileExtension: String? {
    return "css"
  }

  public var snapshotFormat: String {
    return render(config: pretty, css: self)
  }
}
