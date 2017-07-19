import XCTest
import Prelude
import Css
import CssTestSupport
import SnapshotTesting

class FullStylesheetTests: XCTestCase {

  func testABigStyleSheet() {
    let css: Stylesheet =
      body % (
        .background(red)
          <> (a & .pseudo(.firstChild)) % (
            .color(blue)
        )
    )
    <> (ul ** li) % (
      .color(red)
        <> (.pseudo(.firstChild)) & (
          .color(blue)
      )
    )

    assertSnapshot(matching: css)
  }
}
