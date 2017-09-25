import XCTest
import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting

private let conn = connection(from: URLRequest(url: URL(string: "/")!))

class HttpPipelineTests: XCTestCase {
  func testPipeline() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> respond(text: "Hello, world")

    assertSnapshot(matching: middleware(conn))
  }

  func testHtmlResponse() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))
  }

  func testRedirect() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> = redirect(to: "/sign-in")

    assertSnapshot(matching: middleware(conn))
  }

  func testRedirect_AdditionalHeaders() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      redirect(to: "/sign-in", headersMiddleware: writeHeader("Pass-through", "hello!"))

    assertSnapshot(matching: middleware(conn))
  }

  func testWriteHeaders() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> writeHeader("Z", "Header should be last")
        >>> writeHeader("Hello", "World")
        >>> writeHeader("Goodbye", "World")
        >>> writeHeader("A", "Header should be first")
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))
  }

  func testCookies() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> writeHeader(.setCookie(["user_id": "123456"]))
        >>> writeHeader(.setCookie(["lang": "es"]))
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))
  }
}
