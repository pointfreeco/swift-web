import DoctorPretty
import Html
import HtmlPrettyPrint
import SnapshotTesting
import XCTest

class PrettyTests: XCTestCase {

  func testPretty() {
    let doc: Node = .document(
      [
        html(
          [
            body(
              [
                .comment("This is gonna be a long comment. Let's see what happens!"),
                div(
                  [
                    div(
                      [
                        id("some-long-id"),
                        Html.`class`("foo bar baz class1 class2 class3"),
                        style("color: red;background: blue;padding: rem(2);")
                      ],
                      ["hello world"]
                    ),
                    p([
                      """
    Tacit programming, also called point-free style, is a programming paradigm in which function definitions do not identify the arguments (or "points") on which they operate.
    """
    ]),
                    img([ id("cat"), Html.`class`("cat"), src("cat.jpg") ])
                  ]
                )
              ]
            )
          ]
        )
      ]
    )

    assertSnapshot(matching: prettyPrint(node: doc, pageWidth: 40), pathExtension: "html")
  }
}
