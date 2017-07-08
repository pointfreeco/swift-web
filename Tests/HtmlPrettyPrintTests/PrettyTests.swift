import DoctorPretty
import Html
import HtmlPrettyPrint
import XCTest

class PrettyTests: XCTestCase {

  func testPretty() {
    let doc: Node = .document(
      [
        body(
          [
            .comment("This is gonna be a long comment. I wonder what is going to happen!"),
            div(
              [
                div(
                  [
                    id("some-long-id"),
                    Html.`class`("foo bar baz"),
                    style("color: red;")
                  ],
                  ["hello world"]
                ),
                p(["goodbye world"]),
              ]
            )
          ]
        )
      ]
    )

    XCTAssertEqual(
      """
<!DOCTYPE html>
<body>
  <!-- This is gonna be a long
       comment. I wonder what
       is going to happen! -->
  <div>
    <div id="some-long-id"
         class="foo bar baz"
         style="color: red;">
      hello world
    </div>
    <p>
      goodbye world
    </p>
  </div>
</body>
""",
      prettyPrint(node: doc, pageWidth: 30))
  }
}
