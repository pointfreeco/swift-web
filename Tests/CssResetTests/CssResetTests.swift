import Css
import CssReset
import CssTestSupport
import Prelude
import XCTest
import SnapshotTesting

class ResetTests: XCTestCase {
  func testResetPretty() {
    assertSnapshot(matching: reset, as: .css)
  }

  func testResetCompact() {
    assertSnapshot(matching: reset, as: .css(.compact))
  }
}
