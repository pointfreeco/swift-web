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
        <> outlineWidth(all: .none)
        <> outlineColor(all: .none)
    )
    <> input["type"=="submit"] % (
      boxShadow(stroke: .inset, x: .px(1), y: .px(1), color: .rgba(0, 0, 0, 1))
    )

    assertSnapshot(matching: css)
  }
}
