import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting
import XCTest

private let conn = connection(from: URLRequest(url: URL(string: "/")!), defaultHeaders: [])

class SignedCookieTests: XCTestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testSignedCookie() {
    let secret = "cce35c66b1c158d0fdbe93284ab0d2e2003daa0033c4d49753ea8147bdb5a29e30b35d46d5bbad89a6916b9a"
    let signedCookieValue = """
aGVsbG8td29ybGQ=\
--\
4wgeyWTkB2EKsLHYK7Ao1VzjFMXeTLZHXX76XTTOBCw=
"""

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> writeHeaders(
          [.setSignedCookie(key: "session", value: "hello-world", secret: secret)]
            |> catOptionals
        )
        >=> end

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)

    XCTAssertEqual(
      "hello-world",
      Response.Header.verifiedString(signedCookieValue: signedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      nil,
      Response.Header.verifiedString(signedCookieValue: signedCookieValue, secret: "deadbeef"),
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

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> writeHeaders(
          [.setSignedCookie(key: "session", value: episode, secret: secret)]
            |> catOptionals
        )
        >=> end

    #if !os(Linux)
      assertSnapshot(matching: middleware(conn).perform(), as: .conn)
    #endif

    XCTAssertEqual(
      episode,
      Response.Header.verifiedValue(signedCookieValue: signedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      Episode?.none,
      Response.Header.verifiedValue(signedCookieValue: signedCookieValue, secret: "deadbeef"),
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

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> writeHeaders(
          [.setSignedCookie(key: "session", value: "hello-world", secret: secret, encrypt: true)]
            |> catOptionals
        )
        >=> end

    assertSnapshot(matching: middleware(conn).perform(), as: .conn)

    XCTAssertEqual(
      "hello-world",
      Response.Header.verifiedString(signedCookieValue: encryptedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      nil,
      Response.Header.verifiedString(
        signedCookieValue: encryptedCookieValue,
        secret: "deadbeefdeadbeefdeadbeefdead1234"
      ),
      "Reading signed cookie with wrong credentials returns nil."
    )
  }

  func testEncryptedCookie_EncodableValue() {
    let secret = "deadbeefdeadbeefdeadbeefdeadbeef"
    let encryptedCookieValue = """
674d4b73680a254d2b881823a221ac05\
58da40e24cb393d39f4539c9229805eb\
33873047a29a03a6b5206bdd5be1f391\
4bd04763062925247727d2953b74a707\
7e47c94b32c5fd246917a2ea0726f36a\
cb4db8ac9390ac810837809f11bc6803\
639d849d1d43ac0082b7e3aaedfd8174
"""
    let episode = Episode(id: 42, name: "All About Functions")

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      writeStatus(.ok)
        >=> writeHeaders(
          [.setSignedCookie(key: "session", value: episode, secret: secret, encrypt: true)]
            |> catOptionals
        )
        >=> end

    #if !os(Linux)
      assertSnapshot(matching: middleware(conn).perform(), as: .conn)
    #endif

    XCTAssertEqual(
      episode,
      Response.Header.verifiedValue(signedCookieValue: encryptedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      Episode?.none,
      Response.Header.verifiedValue(
        signedCookieValue: encryptedCookieValue,
        secret: "deadbeefdeadbeefdeadbeefdead1234"
      ),
      "Reading signed cookie with wrong credentials returns nil."
    )
  }
}

private struct Episode: Codable, Equatable {
  let id: Int
  let name: String
}
