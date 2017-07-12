import Css
import CssReset
import CssTestSupport
import Prelude
import XCTest
import SnapshotTesting

class ResetTests: XCTestCase {
  func testResetPretty() {
    assertSnapshot(matching: reset)
  }

  func testResetCompact() {
    assertSnapshot(matching: render(config: compact, css: reset))
  }
}
