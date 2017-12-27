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
    let selector: CssSelector = .class("p1") | .class("m2")
    let document = html([
      head([
        style(css)
        ]),
      body([
        p([HtmlCssSupport.`class`([selector]), style(color(.blue))], ["Hellow world"])
        ])
      ])

    XCTAssertEqual(
      """
<html>
  <head>
    <style>
      body{color:#ff0000}
    </style>
  </head>
  <body>
    <p class="p1 m2" style="color:#0000ff;">
      Hellow world
    </p>
  </body>
</html>
""",
      prettyPrint(node: document)
    )
  }
}
