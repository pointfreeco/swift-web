import XCTest
import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting

private let conn = connection(from: URLRequest(url: URL(string: "/")!))

class SharedMiddlewareTransformersTests: XCTestCase {
  override func setUp() {
    record = true
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

  func testBasicAuth_Unauthorized() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      basicAuth(user: "Hello", password: "World")
        <| writeStatus(.ok) >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))
  }

  func testBasicAuth_Authorized() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      basicAuth(user: "Hello", password: "World")
        <| writeStatus(.ok) >>> respond(html: "<p>Hello, world</p>")

    let conn = connection(
      from: URLRequest(url: URL(string: "/")!)
        |> \.allHTTPHeaderFields .~ ["Authorization": "Basic SGVsbG86V29ybGQ="]
    )

    assertSnapshot(matching: middleware(conn))
  }

  func testContentLengthMiddlewareTransformer() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      contentLength
        <| writeStatus(.ok)
        >>> writeHeader(.contentType(.html))
        >>> closeHeaders
        >>> map(const(Data()))
        >>> send("<p>Hello, world</p>".data(using: .utf8))
        >>> end

    assertSnapshot(matching: middleware(conn))
  }
}
