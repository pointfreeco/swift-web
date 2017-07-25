import Css
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import XCTest

class SupportTests: XCTestCase {
  func testStyleAttribute() {
    let sheet = color(.red)
    let node = p(
      [ style(sheet) ],
      [ "Hello world!" ]
    )

    XCTAssertEqual(
      "<p style=\"color:#ff0000\">Hello world!</p>",
      render(node, config: compact)
    )
  }

  func testStyleElement() {
    let css = body % color(.red)
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
      prettyPrint(node: document)
    )
  }
}
