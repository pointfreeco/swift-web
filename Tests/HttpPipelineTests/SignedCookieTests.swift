import Deriving
import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting
import XCTest

private let conn = connection(from: URLRequest(url: URL(string: "/")!))

class SignedCookieTests: XCTestCase {
  func testSignedCookie() {
    let secret = "cce35c66b1c158d0fdbe93284ab0d2e2003daa0033c4d49753ea8147bdb5a29e30b35d46d5bbad89a6916b9a"
    let signedCookieValue = """
aGVsbG8td29ybGQ=\
--\
4wgeyWTkB2EKsLHYK7Ao1VzjFMXeTLZHXX76XTTOBCw=
"""

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
eyJpZCI6NDIsIm5hbWUiOiJBbGwgQWJvdXQgRnVuY3Rpb25zIn0=\
--\
6nCh0Of4anIuD8+6EgYj+g6hOf4wvwiZr6lDodIc+z0=
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

  func testEncryptedCookie() {
    let secret = "deadbeefdeadbeefdeadbeefdeadbeef"
    let encryptedCookieValue = """
42486a73fb0573701336550a1bb0e96d\
2360158e38ef1b13a944f98147463a06\
71abfc5cd6e58c17c200f0211dbf5bb2\
68fe5aaecd5cfad403ffad8ae6d0f116
"""

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data?> =
      writeStatus(.ok)
        >>> writeHeaders(
          [
            .setSignedCookie(
              key: "session",
              value: "hello-world",
              options: [.secure, .httpOnly],
              secret: secret,
              encrypt: true
            )
            ] |> catOptionals
        )
        >>> respond(html: "<p>Hello, world</p>")

    assertSnapshot(matching: middleware(conn))

    XCTAssertEqual(
      "hello-world",
      ResponseHeader.verifiedString(signedCookieValue: encryptedCookieValue, secret: secret, decrypt: true),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      nil,
      ResponseHeader.verifiedString(
        signedCookieValue: encryptedCookieValue,
        secret: "deadbeefdeadbeefdeadbeefdead1234"
      ),
      "Reading signed cookie with wrong credentials returns nil."
    )
  }
}

struct Episode: Codable, DerivingEquatable {
  let id: Int
  let name: String
}
