import Css
import CssReset
import CssTestSupport
import Prelude
import XCTest
import SnapshotTesting

class ResetTests: SnapshotTestCase {
  func testResetPretty() {
    assertSnapshot(matching: reset)
  }

  func testResetCompact() {
    assertSnapshot(of: .css(.compact), matching: reset)
  }
}
