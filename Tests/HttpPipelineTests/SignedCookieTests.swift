#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HttpPipeline
import HttpPipelineTestSupport
import HTTPTypes
import Optics
import Prelude
import InlineSnapshotTesting
import XCTest
import Crypto

private let conn = connection(from: Request(url: URL(string: "https://example.com")!))

class SignedCookieTests: XCTestCase {
  override func setUp() {
    super.setUp()
//    isRecording=true
  }

  @MainActor
  func testSignedCookie() async {
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

    let response = await middleware(conn).performAsync()
    assertInlineSnapshot(of: response, as: .conn) {
      """
      GET https://example.com/

      200 OK
      Set-Cookie: session=aGVsbG8td29ybGQ=--4wgeyWTkB2EKsLHYK7Ao1VzjFMXeTLZHXX76XTTOBCw=; HttpOnly
      """
    }

    XCTAssertEqual(
      "hello-world",
      HTTPField.verifiedString(signedCookieValue: signedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      nil,
      HTTPField.verifiedString(signedCookieValue: signedCookieValue, secret: "deadbeef"),
      "Reading signed cookie with wrong credentials returns nil."
    )
  }

  @MainActor
  func testSignedCookie_EncodableValue() async {
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
      let response = await middleware(conn).performAsync()
      assertInlineSnapshot(of: response, as: .conn) {
          """
          GET https://example.com/

          200 OK
          Set-Cookie: session=eyJpZCI6NDIsIm5hbWUiOiJBbGwgQWJvdXQgRnVuY3Rpb25zIn0=--6nCh0Of4anIuD8+6EgYj+g6hOf4wvwiZr6lDodIc+z0=; HttpOnly
          """
      }
    #endif

    XCTAssertEqual(
      episode,
      HTTPField.verifiedValue(signedCookieValue: signedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      Episode?.none,
      HTTPField.verifiedValue(signedCookieValue: signedCookieValue, secret: "deadbeef"),
      "Reading signed cookie with wrong credentials returns nil."
    )
  }

  @MainActor
  func testEncryptedCookie() async {
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
          [.setSignedCookie(key: "session", value: "hello-world", secret: secret, encrypt: true, nonce: .init(repeating: 0, count: 12))]
            |> catOptionals
        )
        >=> end

    let response = await middleware(conn).performAsync()
    assertInlineSnapshot(of: response, as: .conn) {
      """
      GET https://example.com/

      200 OK
      Set-Cookie: session=000000000000000000000000650a48c1711ffad3738b69c529d9642a152fc39bbae504afbb93aabdd579587a9a2f5ebe5ecc88f1f00d329d22f97a451a9bf7505267ce3a607d2fe0cd07b3c5490abf89709726a9069814e0cfeb; HttpOnly
      """
    }

    XCTAssertEqual(
      "hello-world",
      HTTPField.verifiedString(signedCookieValue: encryptedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      nil,
      HTTPField.verifiedString(
        signedCookieValue: encryptedCookieValue,
        secret: "deadbeefdeadbeefdeadbeefdead1234"
      ),
      "Reading signed cookie with wrong credentials returns nil."
    )
  }

  @MainActor
  func testEncryptedCookie_EncodableValue() async {
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
          [.setSignedCookie(key: "session", value: episode, secret: secret, encrypt: true, nonce: .init(repeating: 0, count: 12))]
            |> catOptionals
        )
        >=> end

    #if !os(Linux)
      let response = await middleware(conn).performAsync()
      assertInlineSnapshot(of: response, as: .conn) {
          """
          GET https://example.com/

          200 OK
          Set-Cookie: session=000000000000000000000000613454c2491b8b9159fd19cf02f3007f5a55c58ba4e72fb5ee9aec80f66473278f2041ba56cd9fceff4b01802e9822146bda865f1d3ac434257200e7fc023e15228b8035b58453afbb02e865076e6c7698c5af99bcb8510164533e43e19e9f7df43eacab743676040536b4d2e45c9b3b7094; HttpOnly
          """
      }
    #endif

    XCTAssertEqual(
      episode,
      HTTPField.verifiedValue(signedCookieValue: encryptedCookieValue, secret: secret),
      "Reading signed cookie with proper credentials recovers the value."
    )

    XCTAssertEqual(
      Episode?.none,
      HTTPField.verifiedValue(
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
