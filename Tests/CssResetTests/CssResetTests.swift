import Css
import CssReset
import CssTestSupport
import Prelude
import XCTest
import SnapshotTesting

#if !os(Linux)
typealias SnapshotTestCase = XCTestCase
#endif

class ResetTests: SnapshotTestCase {
  func testResetPretty() {
    assertSnapshot(matching: reset)
  }

  func testResetCompact() {
    assertSnapshot(matching: reset, as: .css(.compact))
  }
}
