import XCTest
import Prelude
import CSS

class FullStylesheetTests: XCTestCase {

  func testABigStyleSheet() {
    let css: Stylesheet =
      body % (
        background(red)
          <> (a & .pseudo(.firstChild)) % (
            color(blue)
        )
    )
    <> (ul ** li) % (
      color(red)
        <> (.pseudo(.firstChild)) & (
          color(blue)
      )
    )

    XCTAssertEqual(
      """

body {
  background : #ff0000;
}

body a:first-child {
  color : #0000ff;
}

ul li {
  color : #ff0000;
}

ul li:first-child {
  color : #0000ff;
}


""",
      render(config: pretty, css: css)
    )
  }
}
