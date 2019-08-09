import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting
import XCTest

private let conn = connection(from: URLRequest(url: URL(string: "/")!), defaultHeaders: [])

class HttpPipelineTests: XCTestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testPipeline() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> respond(text: "Hello, world")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testHtmlResponse() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testRedirect() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> = redirect(to: "/sign-in")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testRedirect_AdditionalHeaders() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      redirect(to: "/sign-in", headersMiddleware: writeHeader("Pass-through", "hello!"))

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testWriteHeaders() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> writeHeader("Z", "Header should be last")
        >=> writeHeader("Hello", "World")
        >=> writeHeader("Goodbye", "World")
        >=> writeHeader("A", "Header should be first")
        >=> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testCookies() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> writeHeader(.setCookie("user_id", "123456"))
        >=> writeHeader(.setCookie("lang", "es"))
        >=> writeHeader(.clearCookie("test"))
        >=> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testCookieOptions() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> writeHeader(.setCookie("foo", "bar", [.domain("www.pointfree.co")]))
        >=> writeHeader(.setCookie("foo", "bar", [.expires(Date(timeIntervalSince1970: 1234567890))]))
        >=> writeHeader(.setCookie("foo", "bar", [.httpOnly]))
        >=> writeHeader(.setCookie("foo", "bar", [.maxAge(3600)]))
        >=> writeHeader(.setCookie("foo", "bar", [.path("/path/to/some/where")]))
        >=> writeHeader(.setCookie("foo", "bar", [.sameSite(.lax)]))
        >=> writeHeader(.setCookie("foo", "bar", [.sameSite(.strict)]))
        >=> writeHeader(.setCookie("foo", "bar", [.secure]))
        >=> writeHeader(
          .setCookie("foo", "bar", [.domain("www.pointfree.co"), .httpOnly, .secure])
        )
        >=> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }
}
