#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting
import XCTest

private let conn = connection(from: URLRequest(url: URL(string: "/")!))

class HttpPipelineTests: XCTestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  @MainActor
  func testPipeline() async {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> respond(text: "Hello, world")

    let response = await middleware(conn).performAsync()
    assertSnapshot(matching: response, as: .conn)
  }

  @MainActor
  func testHtmlResponse() async {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> respond(html: "<p>Hello, world</p>")

    let response = await middleware(conn).performAsync()
    assertSnapshot(matching: response, as: .conn)
  }

  @MainActor
  func testRedirect() async {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> = redirect(to: "/sign-in")

    let response = await middleware(conn).performAsync()
    assertSnapshot(matching: response, as: .conn)
  }

  @MainActor
  func testRedirect_AdditionalHeaders() async {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
    redirect(to: "/sign-in", headersMiddleware: writeHeader(.init("Pass-through")!, "hello!"))

    let response = await middleware(conn).performAsync()
    assertSnapshot(matching: response, as: .conn)
  }

  @MainActor
  func testWriteHeaders() async {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
    >=> writeHeader(.init("Z")!, "Header should be last")
    >=> writeHeader(.init("Hello")!, "World")
    >=> writeHeader(.init("Goodbye")!, "World")
    >=> writeHeader(.init("A")!, "Header should be first")
        >=> respond(html: "<p>Hello, world</p>")

    let response = await middleware(conn).performAsync()
    assertSnapshot(matching: response, as: .conn)
  }

  @MainActor
  func testCookies() async {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> writeHeader(.setCookie("user_id", "123456"))
        >=> writeHeader(.setCookie("lang", "es"))
        >=> writeHeader(.clearCookie("test"))
        >=> respond(html: "<p>Hello, world</p>")

    let response = await middleware(conn).performAsync()
    assertSnapshot(matching: response, as: .conn)
  }

  @MainActor
  func testCookieOptions() async {
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

    let response = await middleware(conn).performAsync()
    assertSnapshot(matching: response, as: .conn)
  }
}
