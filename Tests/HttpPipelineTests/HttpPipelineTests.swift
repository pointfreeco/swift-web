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
        >>> writeHeader(.setCookie(key: "user_id", value: "123456", options: []))
        >>> writeHeader(.setCookie(key: "lang", value: "es", options: []))
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))
  }

  func testCookieOptions() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> writeHeader(.setCookie(key: "domain", value: "1", options: [.domain("www.pointfree.co")]))
        >>> writeHeader(.setCookie(key: "httpOnly", value: "2", options: [.httpOnly]))
        >>> writeHeader(.setCookie(key: "maxAge", value: "3", options: [.maxAge(3600)]))
        >>> writeHeader(.setCookie(key: "path", value: "4", options: [.path("/path/to/some/where")]))
        >>> writeHeader(.setCookie(key: "sameSiteLax", value: "5", options: [.sameSite(.lax)]))
        >>> writeHeader(.setCookie(key: "sameSiteStrict", value: "6", options: [.sameSite(.strict)]))
        >>> writeHeader(.setCookie(key: "secure", value: "7", options: [.secure]))
        >>> writeHeader(
          .setCookie(key: "multiple", value: "8", options: [.domain("www.pointfree.co"), .httpOnly, .secure])
        )
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))
  }
}
