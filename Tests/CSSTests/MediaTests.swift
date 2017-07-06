import XCTest
import Prelude
@testable import CSS

class MediaTests: XCTestCase {

  func testMediaQueryOnly() {

    let css =
      body % background(blue)
        <>
        queryOnly(screen, [maxWidth(px(550))]) {
          body % background(red)
    }


    XCTAssertEqual(
      """

body {
  background : #0000ff;
}

@media only screen and (max-width: 550px) {

body {
  background : #ff0000;
}

}

""",
      render(config: pretty, css: css)
    )
  }


  func testMediaQueryNot() {
    let css =
      queryNot(print, [maxWidth(px(550))]) {
        body % background(red)
    }

    XCTAssertEqual(
      """

@media not print and (max-width: 550px) {

body {
  background : #ff0000;
}

}

""",
      render(config: pretty, css: css)
    )
  }
}
