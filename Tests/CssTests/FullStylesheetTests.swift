import XCTest
import Prelude
import Css
import CssTestSupport
import SnapshotTesting

class FullStylesheetTests: XCTestCase {

  func testABigStyleSheet() {
    let css: Stylesheet =
      body % (
        background(Color.red)
          <> (a & .pseudo(.firstChild)) % (
            color(.blue)
        )
    )
    <> (ul ** li) % (
      color(.red)
        <> (.pseudo(.firstChild)) & (
          color(.blue)
      )
    )
    <> input % (
      outlineStyle(all: .none)
        <> outlineWidth(all: 0)
        <> outlineColor(all: .transparent)
    )
    <> input["type"=="submit"] % (
      boxShadow(stroke: .inset, hShadow: .px(1), vShadow: .px(1), color: .rgba(0, 0, 0, 1))
        <> appearance(.button)
    )

    assertSnapshot(matching: css, as: .css)
  }
}
