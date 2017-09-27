import Deriving
import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting
import XCTest

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
        >>> writeHeader(.setCookie(key: "foo", value: "bar", options: [.domain("www.pointfree.co")]))
        >>> writeHeader(.setCookie(key: "foo", value: "bar", options: [.httpOnly]))
        >>> writeHeader(.setCookie(key: "foo", value: "bar", options: [.maxAge(3600)]))
        >>> writeHeader(.setCookie(key: "foo", value: "bar", options: [.path("/path/to/some/where")]))
        >>> writeHeader(.setCookie(key: "foo", value: "bar", options: [.sameSite(.lax)]))
        >>> writeHeader(.setCookie(key: "foo", value: "bar", options: [.sameSite(.strict)]))
        >>> writeHeader(.setCookie(key: "foo", value: "bar", options: [.secure]))
        >>> writeHeader(
          .setCookie(key: "foo", value: "bar", options: [.domain("www.pointfree.co"), .httpOnly, .secure])
        )
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))
  }

  func testSignedCookie() {
    let secret = "cce35c66b1c158d0fdbe93284ab0d2e2003daa0033c4d49753ea8147bdb5a29e30b35d46d5bbad89a6916b9a"
    let signedCookieValue = "aGVsbG8td29ybGQ=--4wgeyWTkB2EKsLHYK7Ao1VzjFMXeTLZHXX76XTTOBCw="

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> writeHeaders(
          [
            .setSignedCookie(
              key: "session",
              value: "hello-world",
              options: [.secure, .httpOnly],
              secret: secret
            )
            ] |> catOptionals
        )
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))

    XCTAssertEqual(
      "hello-world",
      ResponseHeader.verifiedString(signedCookieValue: signedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      nil,
      ResponseHeader.verifiedString(signedCookieValue: signedCookieValue, secret: "deadbeef"),
      "Reading signed cookie with wrong credentials returns nil."
    )
  }

  func testSignedCookie_EncodableValue() {
    let secret = "cce35c66b1c158d0fdbe93284ab0d2e2003daa0033c4d49753ea8147bdb5a29e30b35d46d5bbad89a6916b9a"
    let episode = Episode(id: 42, name: "All About Functions")
    let signedCookieValue = """
eyJpZCI6NDIsIm5hbWUiOiJBbGwgQWJvdXQgRnVuY3Rpb25zIn0=--6nCh0Of4anIuD8+6EgYj+g6hOf4wvwiZr6lDodIc+z0=
"""

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> writeHeaders(
          [
            .setSignedCookie(
              key: "session",
              value: episode,
              options: [.secure, .httpOnly],
              secret: secret
            )
            ] |> catOptionals
        )
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))

    XCTAssertEqual(
      episode,
      ResponseHeader.verifiedValue(signedCookieValue: signedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      Episode?.none,
      ResponseHeader.verifiedValue(signedCookieValue: signedCookieValue, secret: "deadbeef"),
      "Reading signed cookie with wrong credentials returns nil."
    )
  }
}

struct Episode: Codable, DerivingEquatable {
  let id: Int
  let name: String
}
