import HttpPipeline
import XCTest

class EncryptionTests: XCTestCase {

  func testEncrypt() {
    XCTAssertEqual("af54a6cf18a83a6dc0a38e2895dd1ce4", encrypted(text: "blah", secret: "DeadBeefDeadBeef0123012301230123"))

    // Secret is too short
    XCTAssertNil(encrypted(text: "blah", secret: "deadbeefdeadbeef"))

    // Secret is not valid hex string
    XCTAssertNil(encrypted(text: "blah", secret: "asdfasdfasdfasdfasdfasdfasdfasdf"))
  }

  func testDecrypt() {
    XCTAssertEqual("blah", decrypted(text: "af54a6cf18a83a6dc0a38e2895dd1ce4", secret: "DeadBeefDeadBeef0123012301230123"))

    // Secret is too short
    XCTAssertNil(decrypted(text: "836fdf1bf0008e1be7b352d0ccd42dcb", secret: "deadbeefdeadbeef"))

    // Secret is not valid hex string
    XCTAssertNil(decrypted(text: "836fdf1bf0008e1be7b352d0ccd42dcb", secret: "asdfasdfasdfasdfasdfasdfasdfasdf"))

    // Encrypted text is not even length
    XCTAssertNil(decrypted(text: "8", secret: "deadbeefdeadbeefdeadbeefdeadbeef"))

    // Encrypted text is not valid.
    XCTAssertNil(decrypted(text: "83", secret: "deadbeefdeadbeefdeadbeefdeadbeef"))

    // Encrypted text is not valid hex string.
    XCTAssertNil(decrypted(text: "asdf", secret: "deadbeefdeadbeefdeadbeefdeadbeef"))
  }

  func testDigest() {
    XCTAssertNotNil(digest(value: "ZNeX1idK+rOYKu9jcq7AS9+IBA3wuPWWZeUQchQrLIs=", secret: "deadbeef"))
  }
}
