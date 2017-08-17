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

    assertSnapshot(matching: middleware(conn).response)
  }

  func testHtmlResponse() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).response)
  }

  func testRedirect() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> = redirect(to: "/sign-in")

    assertSnapshot(matching: middleware(conn).response)
  }

  func testRedirect_AdditionalHeaders() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      redirect(to: "/sign-in", headersMiddleware: writeHeader("Pass-through", "hello!"))

    assertSnapshot(matching: middleware(conn).response)
  }

  func testBasicAuth_Unauthorized() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      basicAuth(user: "Hello", password: "World")
        <| writeStatus(.ok) >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).response)
  }

  func testBasicAuth_Authorized() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      basicAuth(user: "Hello", password: "World")
        <| writeStatus(.ok) >>> respond(html: "<p>Hello, world</p>")

    let conn = connection(
      from: URLRequest(url: URL(string: "/")!)
        |> \.allHTTPHeaderFields .~ ["Authorization": "Basic SGVsbG86V29ybGQ="]
    )

    assertSnapshot(matching: middleware(conn).response)
  }

  func testWriteHeaders() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> writeHeader("Hello", "World")
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).response)
  }

  func testCookies() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> writeHeader(.setCookie(["user_id": "123456"]))
        >>> writeHeader(.setCookie(["lang": "es"]))
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).response)
  }
}
