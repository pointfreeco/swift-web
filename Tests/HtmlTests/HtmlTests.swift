import Css
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import Prelude
import XCTest

class HTMLTests: XCTestCase {
  func testImgTag() {
    let html = img(
      [ src <| "cat.jpg",
        width <| 100,
        height <| 100 ]
    )

    let rendered = render(html)

    XCTAssertEqual(
      "<img src=\"cat.jpg\" width=\"100\" height=\"100\">",
      rendered
    )
  }

  func testHtml3() {
    let html = p(
      [ Html.`class` <| "main" ],
      [
        img(
          [ src <| "cat.jpg",
            width <| 100,
            height <| 100 ]
        ),

        "A cat!"
      ]
    )

    XCTAssertEqual(
      "<p class=\"main\"><img src=\"cat.jpg\" width=\"100\" height=\"100\">A cat!</p>",
      render(html)
    )
  }

  func testHtmlTag() {
    let testHtml = html(
      [ id <| "home" ],
      [
        p(
          [],
          [
            "Welcome to point free!"
          ]
        )
      ]
    )

    XCTAssertEqual(
      "<html id=\"home\"><p>Welcome to point free!</p></html>",
      render(testHtml)
    )
  }

  func testATag() {
    let testHtml = html(
      [ id <| "home" ],
      [
        a(
          [
            href <| "/"
          ],
          [
            "Go home!"
          ]
        )
      ]
    )

    XCTAssertEqual(
      "<html id=\"home\"><a href=\"/\">Go home!</a></html>",
      render(testHtml)
    )
  }

  func testHtmlWithInlineStyles() {
    let html = p(
      [ style <| .color(.red) ],
      [
        "Welcome to ",
        a(
          [ style <| .background(Color.blue) ],
          [ "Point Free" ]
        ),
        "!"
      ]
    )

    XCTAssertEqual(
      "<p style=\"color:#ff0000\">Welcome to <a style=\"background:#0000ff\">Point Free</a>!</p>",
      render(html))
  }

  func testHtmlInput() {
    let html = input(
      [ disabled <| true, Html.value <| "Hello, world!" ]
    )

    XCTAssertEqual("<input disabled value=\"Hello, world!\">", render(html))
  }

  func testScriptTag() {
    let html = div([
      script([src <| "app.js"]),
      script("alert(\"Hello!\")")
    ])

    XCTAssertEqual("<div><script src=\"app.js\"></script><script>alert(\"Hello!\")</script></div>", render(html))
  }

  func testPrettyRender() {

    let htmlNode = html(
      [],
      [
        body(
          [
            .comment("Welcome to our app!"),
            h1(["Title"]),
            p(
              [
                "Some text ",
                a(["A link"]),
                "Some more text..."
              ]
            )
          ]
        )
      ]
    )

    XCTAssertEqual(
      """
<html>
  <body>
    <!-- Welcome to our app! -->
    <h1>
      Title
    </h1>
    <p>
      Some text
      <a>
        A link
      </a>
      Some more text...
    </p>
  </body>
</html>
""",
      prettyPrint(node: htmlNode)
    )
  }

  func testDocument() {
    let doc = document([
      html([
        head([
          title("Title")
        ])
      ])
    ])

    XCTAssertEqual("<!DOCTYPE html><html><head><title>Title</title></head></html>", Html.render(doc))
  }
}
