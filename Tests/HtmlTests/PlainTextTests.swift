import Html
import XCTest
import SnapshotTesting

class PlainTextTests: XCTestCase {
  func testPlainText() {
    let doc = document([
      html([
        head([
          style("h1{color: red}"),
          script("alert(\"hello!\");")
          ]),
        body([
          h1(["Welcome!"]),
          p(["Welcome to you & who has come here before."]),
          p([
            "This is a paragraph with ",
            em(["some"]),
            " inline formatting and ",
            a([href("https://example.org")], ["a link"]),
            "!"
            ]),
          p([
            "Here's an ", strong(["ordered"]), " list:"
            ]),
          ol([
            li(["Preheat oven."]),
            li(["Mix ingredients."]),
            li(["Order delivery."])
            ]),
          p([
            "And, \"unordered\":"
            ]),
          ul([
            li(["Milk"]),
            li(["Eggs"]),
            li(["Coffee"])
            ]),
          p([
            "They said:"
            ]),
          blockquote([
            "Code to the interface you wish you had, not the interface you were given."
            ])
          ]),
        ])
      ])

    assertSnapshot(matching: plainText(for: doc))
  }
}
