import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting
import XCTest

private let conn = connection(from: URLRequest(url: URL(string: "/")!))

class HttpPipelineTests: XCTestCase {
//  override func setUp() {
//    super.setUp()
//    record = true
//  }

  
  func testPipeline() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >-> respond(text: "Hello, world")

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testHtmlResponse() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >-> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testRedirect() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> = redirect(to: "/sign-in")

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testRedirect_AdditionalHeaders() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      redirect(to: "/sign-in", headersMiddleware: writeHeader("Pass-through", "hello!"))

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testWriteHeaders() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >-> writeHeader("Z", "Header should be last")
        >-> writeHeader("Hello", "World")
        >-> writeHeader("Goodbye", "World")
        >-> writeHeader("A", "Header should be first")
        >-> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testCookies() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >-> writeHeader(.setCookie(key: "user_id", value: "123456", options: []))
        >-> writeHeader(.setCookie(key: "lang", value: "es", options: []))
        >-> writeHeader(.clearCookie(key: "test"))
        >-> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testCookieOptions() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >-> writeHeader(.setCookie(key: "foo", value: "bar", options: [.domain("www.pointfree.co")]))
        >-> writeHeader(.setCookie(key: "foo", value: "bar", options: [.expires(1234567890)]))
        >-> writeHeader(.setCookie(key: "foo", value: "bar", options: [.httpOnly]))
        >-> writeHeader(.setCookie(key: "foo", value: "bar", options: [.maxAge(3600)]))
        >-> writeHeader(.setCookie(key: "foo", value: "bar", options: [.path("/path/to/some/where")]))
        >-> writeHeader(.setCookie(key: "foo", value: "bar", options: [.sameSite(.lax)]))
        >-> writeHeader(.setCookie(key: "foo", value: "bar", options: [.sameSite(.strict)]))
        >-> writeHeader(.setCookie(key: "foo", value: "bar", options: [.secure]))
        >-> writeHeader(
          .setCookie(key: "foo", value: "bar", options: [.domain("www.pointfree.co"), .httpOnly, .secure])
        )
        >-> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform())
  }
}
