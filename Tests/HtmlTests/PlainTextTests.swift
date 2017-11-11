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
          p(["Welcome to you, who has come here"]),
          p([
            "This is a paragraph with ",
            em(["some"]),
            " inline formatting."
            ])
          ])
        ])
      ])

    assertSnapshot(matching: plainText(for: doc))
  }
}
