import Html
import XCTest
import SnapshotTesting
import HtmlPlainTextPrint

class PlainTextTests: XCTestCase {
  func testPlainText() async {
    let doc = Node.html(
      .head(
        .title("Hello!"),
        .style(unsafe: "h1{color: red}")
      ),
      .body(
        .p(attributes: [.style(unsafe: "display:none")], "Hide me pls!"),
        .p(attributes: [.style(unsafe: " display: none !important; ")], "And me!"),
        .h1("Welcome!"),
        .p("Welcome to you & who has come here before."),
        .p(
          "This is a paragraph with ",
          .em("some"),
          " inline formatting and ",
          .a(attributes: [.href("https://example.org")], "a link"),
          "!"
        ),
        .p(
          "Here's an ", .strong("ordered"), " list:"
        ),
        .ol(
          .li("Preheat oven."),
          .li("Mix ingredients."),
          .li("Order delivery.")
        ),
        .p(
          "And, \"unordered\":"
        ),
        .ul(
          .li("Milk"),
          .li("Eggs"),
          .li("Coffee")
        ),
        .p(
          "They said:"
        ),
        .blockquote(
          "Code to the interface you wish you had, not the interface you were given."
        ),
        .script(unsafe: "alert(\"hello!\");")
      )
    )

    await assertSnapshot(matching: HtmlPlainTextPrint.plainText(for: doc), as: .lines)
  }
}
