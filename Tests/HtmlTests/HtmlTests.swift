import Css
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import HtmlTestSupport
import Prelude
import SnapshotTesting
import XCTest

class HTMLTests: XCTestCase {
  func testImgTag() {
    let html = img(
      [ src <| "cat.jpg",
        width <| 100,
        height <| 100 ]
    )

    assertSnapshot(matching: html)
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

    assertSnapshot(matching: html)
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

    assertSnapshot(matching: testHtml)
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

    assertSnapshot(matching: testHtml)
  }

  func testHtmlWithInlineStyles() {
    let html = p(
      [ style <| color(red) ],
      [
        "Welcome to ",
        a(
          [ style <| background(blue) ],
          [ "Point Free" ]
        ),
        "!"
      ]
    )

    assertSnapshot(matching: html)
  }

  func testHtmlInput() {
    let html = input(
      [ disabled <| true, Html.value <| "Hello, world!" ]
    )

    assertSnapshot(matching: html)
  }

  func testScriptTag() {
    let html = div([
      script([src <| "app.js"]),
      script("alert(\"Hello!\")")
    ])

    assertSnapshot(matching: html)
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

    assertSnapshot(matching: htmlNode)
  }

  func testDocument() {
    let doc = document([
      html([
        head([
          title("Title")
        ])
      ])
    ])

    assertSnapshot(matching: doc)
  }
}
