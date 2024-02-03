import XCTest
import Prelude
import Css
import CssTestSupport
import SnapshotTesting

class FlexBoxTests: XCTestCase {

  func testFlexBox() {
    let css: Stylesheet =
      ".wrapper" % (
        display(.flex)
          <> flex(direction: .row, wrap: .wrap)
          <> .star % (
            flex(grow: 1, basis: .pct(100))
          )
        )
        <> ".main" % (
          flex(grow: 1, basis: .auto)
            <> align(items: .center)
            <> justify(content: .center)

        )
        <> ".aside-1" % order(1)
        <> ".aside-2" % order(2)
        <> ".aside-3" % order(3)

    assertSnapshot(matching: css, as: .css)
  }
}
