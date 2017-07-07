import XCTest
import Prelude
import Css

class SizeTests: XCTestCase {

  func testCalc() {
    let css: Stylesheet = img % (
      width(pct(25) - px(20))
        <> margin(all: px(10))
    )

    XCTAssertEqual(
      """

img {
  width         : -webkit-calc(25% - 20px);
  width         : -moz-calc(25% - 20px);
  width         : -ms-calc(25% - 20px);
  width         : -o-calc(25% - 20px);
  width         : calc(25% - 20px);
  margin-top    : 10px;
  margin-right  : 10px;
  margin-bottom : 10px;
  margin-left   : 10px;
}


""",
      render(config: pretty, css: css)
    )
  }
}
