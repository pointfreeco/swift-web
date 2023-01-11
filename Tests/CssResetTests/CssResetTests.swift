import Css
import CssReset
import CssTestSupport
import Prelude
import XCTest
import SnapshotTesting

class ResetTests: XCTestCase {
  func testResetPretty() async {
    await assertSnapshot(matching: reset, as: .css)
  }

  func testResetCompact() async {
    await assertSnapshot(matching: reset, as: .css(.compact))
  }
}
