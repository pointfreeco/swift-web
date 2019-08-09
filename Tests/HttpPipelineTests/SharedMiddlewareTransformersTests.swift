import XCTest
import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting

private let conn = connection(from: URLRequest(url: URL(string: "/")!), defaultHeaders: [])

class SharedMiddlewareTransformersTests: XCTestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testBasicAuth_Unauthorized() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      basicAuth(user: "Hello", password: "World")
        <| writeStatus(.ok)
        >=> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testBasicAuth_Unauthorized_ProtectedPredicate() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      basicAuth(user: "Hello", password: "World", protect: const(false))
        <| writeStatus(.ok)
        >=> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testBasicAuth_Unauthorized_Realm() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      basicAuth(user: "Hello", password: "World", realm: "Point-Free")
        <| writeStatus(.ok)
        >=> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testBasicAuth_Unauthorized_CustomFailure() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      basicAuth(
        user: "Hello",
        password: "World",
        failure: respond(text: "Custom authentication page!")
        )
        <| writeStatus(.ok)
        >=> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testBasicAuth_Authorized() {
    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      basicAuth(user: "Hello", password: "World")
        <| writeStatus(.ok)
        >=> respond(html: "<p>Hello, world</p>")

    let conn = connection(
      from: URLRequest(url: URL(string: "/")!)
        |> \.allHTTPHeaderFields .~ ["Authorization": "Basic SGVsbG86V29ybGQ="],
      defaultHeaders: []
    )

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)
  }

  func testRedirectUnrelatedHosts() {
    let allowedHosts = [
      "www.pointfree.co",
      "127.0.0.1",
      "localhost",
      "0.0.0.0",
    ]

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      redirectUnrelatedHosts(allowedHosts: allowedHosts, canonicalHost: "www.pointfree.co")
        <| writeStatus(.ok)
        >=> writeHeader(.contentType(.html))
        >=> closeHeaders
        >=> map(const(Data())) >>> pure
        >=> send(Data("<p>Hello, world</p>".utf8))
        >=> end

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!), defaultHeaders: [])).perform(),
      as: .conn
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080")!), defaultHeaders: [])).perform(),
      as: .conn
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://pointfree.co")!), defaultHeaders: [])).perform(),
      as: .conn
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://www.point-free.co")!), defaultHeaders: [])).perform(),
      as: .conn
    )
  }

  func testRequireHerokuHttps() {
    let allowedInsecureHosts = [
      "127.0.0.1",
      "localhost",
      "0.0.0.0",
      ]

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
        <| writeStatus(.ok)
        >=> writeHeader(.contentType(.html))
        >=> closeHeaders
        >=> map(const(Data())) >>> pure
        >=> send(Data("<p>Hello, world</p>".utf8))
        >=> end

    func securedConnection(from request: URLRequest) -> Conn<StatusLineOpen, Prelude.Unit> {
      var result = request
      result.allHTTPHeaderFields = result.allHTTPHeaderFields ?? [:]
      result.allHTTPHeaderFields?["X-Forwarded-Proto"] = "https"
      return connection(from: result, defaultHeaders: [])
    }

    assertSnapshot(
      matching: middleware(securedConnection(from: URLRequest(url: URL(string: "https://www.pointfree.co")!))).perform(),
      as: .conn
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "https://www.pointfree.co")!), defaultHeaders: [])).perform(),
      as: .conn
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080")!), defaultHeaders: [])).perform(),
      as: .conn
    )
  }

  func testRequireHttps() {
    let allowedInsecureHosts = [
      "127.0.0.1",
      "localhost",
      "0.0.0.0",
      ]

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      requireHttps(allowedInsecureHosts: allowedInsecureHosts)
        <| writeStatus(.ok)
        >=> writeHeader(.contentType(.html))
        >=> closeHeaders
        >=> map(const(Data())) >>> pure
        >=> send(Data("<p>Hello, world</p>".utf8))
        >=> end

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "https://www.pointfree.co")!), defaultHeaders: [])).perform(),
      as: .conn
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!), defaultHeaders: [])).perform(),
      as: .conn
    )
    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080")!), defaultHeaders: [])).perform(),
      as: .conn
    )
  }

  func testRequestLogger() {
    var log: [String] = []
    let uuid = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!
    let middleware = requestLogger(logger: { log.append($0) }, uuid: { uuid })
      <| writeStatus(.ok)
      >=> writeHeader(.contentType(.html))
      >=> respond(html: "<p>Hello, world</p>")

    _ = middleware(conn).perform()

    XCTAssertEqual(2, log.count)
    XCTAssertEqual("DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD [Request] GET /", log[0])
    XCTAssertNotNil(
      try NSRegularExpression(
        pattern: "^DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD \\[Time\\] \\d+ms$",
        options: []
      ).firstMatch(
        in: log[1],
        options: [],
        range: NSRange(log[1].startIndex..<log[1].endIndex, in: log[1])
      )
    )
  }
  
  func testBasicAuthValidationIsCaseInsensitive() {
    let urlRequestWithUppercaseAuthorizationHeader = URLRequest(url: URL(string: "/")!)
      |> \.allHTTPHeaderFields .~ ["Authorization": "Basic SGVsbG86V29ybGQ="]
    XCTAssertTrue(validateBasicAuth(user: "Hello", password: "World", request: urlRequestWithUppercaseAuthorizationHeader))

    let urlRequestWithLowercasedAuthorizationHeader = URLRequest(url: URL(string: "/")!)
      |> \.allHTTPHeaderFields .~ ["authorization": "Basic SGVsbG86V29ybGQ="]
    XCTAssertTrue(validateBasicAuth(user: "Hello", password: "World", request: urlRequestWithLowercasedAuthorizationHeader))
  }
}
