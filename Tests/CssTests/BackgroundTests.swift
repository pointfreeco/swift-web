import XCTest
import Prelude
import Css

class BackgroundTests: XCTestCase {
  func testBackground_RGBA() {

    let css: Stylesheet = .background(rgba(200, 100, 50, 1))

    XCTAssertEqual("background:#c86432", render(config: inline, css: css))
  }
}
