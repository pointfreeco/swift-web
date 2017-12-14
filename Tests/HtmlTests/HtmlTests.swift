import Css
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import Prelude
import SnapshotTesting
import XCTest

class HTMLTests: XCTestCase {
  func testImgTag() {
    let html = img(
      src: "cat.jpg",
      alt: "", [
        width <| 100,
        height <| 100
      ]
    )

    let rendered = render(html)

    XCTAssertEqual(
      "<img src=\"cat.jpg\" alt=\"\" width=\"100\" height=\"100\">",
      rendered
    )
  }

  func testHtml3() {
    let html = p(
      [ Html.class <| "main" ],
      [
        img(
          src: "cat.jpg",
          alt: "", [
            width <| 100,
            height <| 100
          ]
        ),

        "A cat!"
      ]
    )

    XCTAssertEqual(
      "<p class=\"main\"><img src=\"cat.jpg\" alt=\"\" width=\"100\" height=\"100\">A cat!</p>",
      render(html)
    )
  }

  func testHtmlTag() {
    let testHtml = html(
      [ id <| "home" ],
      [
        body(
          [
            p(["Welcome to point free!"])
          ]
        )
      ]
    )

    XCTAssertEqual(
      "<html id=\"home\"><body><p>Welcome to point free!</p></body></html>",
      render(testHtml)
    )
  }

  func testATag() {
    let testHtml = html(
      [ id <| "home" ],
      [
        body(
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
      ]
    )

    XCTAssertEqual(
      "<html id=\"home\"><body><a href=\"/\">Go home!</a></body></html>",
      render(testHtml)
    )
  }

  func testHtmlWithInlineStyles() {
    let html = p(
      [ style <| color(.red) ],
      [
        "Welcome to ",
        a(
          [ style <| background(Color.blue) ],
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

    XCTAssertEqual("<div><script src=\"app.js\"></script><script>alert(\"Hello!\")</script></div>",
                   render(html))
  }

  func testPrettyRender() {

    let htmlNode = html(
      [],
      [
        body(
          [
            comment("Welcome to our app!"),
            h1(["Title"]),
            p(
              [
                "Some text",
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

  func testTables() {
    let doc = html([xmlns("http://www.w3.org/1999/xhtml")], [
      head([
        meta([httpEquiv(.contentType), content("text/html; charset=UTF-8")]),
        title(""),
        style("")
        ]),
      body([
        table([border(0), cellpadding(0), cellspacing(0), height(.pct(100)), width(.pct(100)), id("bodyTable")], [
          tr([
            td([align(.center), valign(.top)], [
              table([border(0), cellpadding(20), cellspacing(0), width(.px(600)), id("emailContainer")], [
                tr([
                  td([align(.center), valign(.top)], [
                    "This is where my content goes."
                    ])
                  ])
                ])
              ])
            ])
          ])
        ])
      ])

    assertSnapshot(matching: doc)
  }

  func testBooleanAttributes() {
    let uncheckedInput = input([id("not-checked"), checked(false)])
    XCTAssertEqual("<input id=\"not-checked\">", render(uncheckedInput))

    let checkedInput = input([id("checked"), checked(true)])
    XCTAssertEqual("<input id=\"checked\" checked>", render(checkedInput))
  }
}
