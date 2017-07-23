import XCTest
import Prelude
import Css

class BorderTests: XCTestCase {
  func testBorders() {
    let css = p % (
      .borderRadius(topLeft: 1, topRight: 2, bottomRight: 3, bottomLeft: 4)
        <> .borderColor(top: red, right: blue, bottom: green, left: red)
        <> .borderStyle(top: .solid, right: .dotted, bottom: .dashed, left: .groove)
        <> .borderCollapse(.separate)
        <> .borderWidth(top: 4, right: 3, bottom: 2, left: 1)
    )

    XCTAssertEqual(
      """

p {
  border-top-left-radius     : 1;
  border-top-right-radius    : 2;
  border-bottom-right-radius : 3;
  border-bottom-left-radius  : 4;
  border-top-color           : #ff0000;
  border-right-color         : #0000ff;
  border-bottom-color        : #00ff00;
  border-left-color          : #ff0000;
  border-top-style           : solid;
  border-right-style         : dotted;
  border-bottom-style        : dashed;
  border-left-style          : groove;
  border-collapse            : separate;
  border-top-width           : 4;
  border-right-width         : 3;
  border-bottom-width        : 2;
  border-left-width          : 1;
}


""",
      render(config: pretty, css: css)
    )
  }
}
