import XCTest
import Prelude
import Html
import Css

class EncodedStringTests: XCTestCase {
  func testEscape() {
    let node = body(
      [],
      ["/body><script>alert('BAD')</script>"]
    )

    XCTAssertEqual(
      "<body>/body&gt;&lt;script&gt;alert(&#39;BAD&#39;)&lt;/script&gt;</body>",
      render(node)
    )
  }

  func testDoesntEscapeInStyleTag() {
    let node = head(
      [
        style("/body><script>alert('BAD')</script>")
      ]
    )

    XCTAssertEqual(
      "<head><style>/body><script>alert('BAD')</script></style></head>",
      render(node)
    )
  }

  func testDoesntEscapeInScript() {
    let node = head(
      [
        script("/body><script>alert('BAD')</script>")
      ]
    )

    XCTAssertEqual(
      "<head><script>/body><script>alert('BAD')</script></script></head>",
      render(node)
    )
  }

  func testEscapesAttributeValues() {
    let node = p(
      [ id <| "\"/><script>alert('BAD')</script>" ],
      [ "Hello world!" ]
    )

    XCTAssertEqual(
      "<p id=\"&quot;/&gt;&lt;script&gt;alert(&#39;BAD&#39;)&lt;/script&gt;\">Hello world!</p>",
      render(node)
    )
  }
}
