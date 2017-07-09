import Css
import SnapshotAssertion

extension Stylesheet: Snapshot {
  public var snapshotFormat: String {
    return render(config: pretty, css: self)
  }
}
