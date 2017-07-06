import Css
import Html
import HtmlCssSupport
import XCTest

class SupportTests: XCTestCase {
  func testStyleAttribute() {
    let document = body(
      [ style(color(red)) ],
      [ "Hello world!" ]
    )

    XCTAssertEqual(
      "<body style=\"color:#ff0000\">Hello world!</body>",
      render(document, config: compact)
    )
  }

  func testStyleElement() {
    let css = body % color(red)
    let document = html([head([style(css)])])

    XCTAssertEqual(
      """
<html>
  <head>
    <style>
      body{color:#ff0000}
    </style>
  </head>
</html>

""",
      render(document, config: pretty)
    )
  }
}
