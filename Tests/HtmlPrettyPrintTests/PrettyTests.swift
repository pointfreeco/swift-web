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
                p(["goodbye world"]),
                img([ id("cat"), Html.`class`("cat"), src("cat.jpg") ])
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
  <!-- This is gonna be a long comment.
       Let's see what happens! -->
  <div>
    <div id="some-long-id"
         class="foo
                bar
                baz
                class1
                class2
                class3"
         style="color: red;
                background: blue;
                padding: rem(2);">
      hello world
    </div>
    <p>
      goodbye world
    </p>
    <img id="cat"
         class="cat"
         src="cat.jpg" />
  </div>
</body>
""",
      prettyPrint(node: doc, pageWidth: 40))
  }
}
