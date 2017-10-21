import XCTest
import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting

private let conn = connection(from: URLRequest(url: URL(string: "/")!))

class SharedMiddlewareTransformersTests: XCTestCase {
  func testBasicAuth_Unauthorized() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      basicAuth(user: "Hello", password: "World")
        <| writeStatus(.ok)
        >-> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testBasicAuth_Unauthorized_ProtectedPredicate() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      basicAuth(user: "Hello", password: "World", protect: const(false))
        <| writeStatus(.ok)
        >-> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testBasicAuth_Unauthorized_Realm() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      basicAuth(user: "Hello", password: "World", realm: "Point-Free")
        <| writeStatus(.ok)
        >-> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testBasicAuth_Unauthorized_CustomFailure() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      basicAuth(
        user: "Hello",
        password: "World",
        failure: respond(text: "Custom authentication page!")
        )
        <| writeStatus(.ok)
        >-> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testBasicAuth_Authorized() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      basicAuth(user: "Hello", password: "World")
        <| writeStatus(.ok)
        >-> respond(html: "<p>Hello, world</p>")

    let conn = connection(
      from: URLRequest(url: URL(string: "/")!)
        |> \.allHTTPHeaderFields .~ ["Authorization": "Basic SGVsbG86V29ybGQ="]
    )

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testContentLengthMiddlewareTransformer() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      contentLength
        <| writeStatus(.ok)
        >-> writeHeader(.contentType(.html))
        >-> closeHeaders
        >-> map(const(Data())) >>> pure
        >-> send("<p>Hello, world</p>".data(using: .utf8))
        >-> end

    assertSnapshot(matching: middleware(conn).perform())
  }

  func testRedirectUnrelatedHosts() {
    let allowedHosts = [
      "www.pointfree.co",
      "127.0.0.1",
      "localhost",
      "0.0.0.0",
    ]

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: "www.pointfree.co")
        <| writeStatus(.ok)
        >-> writeHeader(.contentType(.html))
        >-> closeHeaders
        >-> map(const(Data())) >>> pure
        >-> send("<p>Hello, world</p>".data(using: .utf8))
        >-> end

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!))).perform()
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080")!))).perform()
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://pointfree.co")!))).perform()
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://www.point-free.co")!))).perform()
    )
  }

  func testRequireHerokuHttps() {
    let allowedInsecureHosts = [
      "127.0.0.1",
      "localhost",
      "0.0.0.0",
      ]

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
        <| writeStatus(.ok)
        >-> writeHeader(.contentType(.html))
        >-> closeHeaders
        >-> map(const(Data())) >>> pure
        >-> send("<p>Hello, world</p>".data(using: .utf8))
        >-> end

    func securedConnection(from request: URLRequest) -> Conn<StatusLineOpen, Prelude.Unit> {
      var result = request
      result.allHTTPHeaderFields = result.allHTTPHeaderFields ?? [:]
      result.allHTTPHeaderFields?["X-Forwarded-Proto"] = "https"
      return connection(from: result)
    }

    assertSnapshot(
      matching: middleware(securedConnection(from: URLRequest(url: URL(string: "https://www.pointfree.co")!))).perform()
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "https://www.pointfree.co")!))).perform()
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080")!))).perform()
    )
  }

  func testRequireHttps() {
    let allowedInsecureHosts = [
      "127.0.0.1",
      "localhost",
      "0.0.0.0",
      ]

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      requireHttps(allowedInsecureHosts: allowedInsecureHosts)
        <| writeStatus(.ok)
        >-> writeHeader(.contentType(.html))
        >-> closeHeaders
        >-> map(const(Data())) >>> pure
        >-> send("<p>Hello, world</p>".data(using: .utf8))
        >-> end

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "https://www.pointfree.co")!))).perform()
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!))).perform()
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080")!))).perform()
    )
  }
}
