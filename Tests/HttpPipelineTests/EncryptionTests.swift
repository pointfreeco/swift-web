import Deriving
import HttpPipeline
import HttpPipelineTestSupport
import Optics
import Prelude
import SnapshotTesting
import XCTest

class EncryptionTests: XCTestCase {

  func testEncrypt() {
    XCTAssertEqual("af54a6cf18a83a6dc0a38e2895dd1ce4", encrypted(text: "blah", secret: "DeadBeefDeadBeef0123012301230123"))

    XCTAssertNil(encrypted(text: "blah", secret: "deadbeefdeadbeef"))
    XCTAssertNil(encrypted(text: "blah", secret: "asdfasdfasdfasdfasdfasdfasdfasdf"))
  }

  func testDecrypt() {
    XCTAssertEqual("blah", decrypted(text: "af54a6cf18a83a6dc0a38e2895dd1ce4", secret: "DeadBeefDeadBeef0123012301230123"))

    XCTAssertNil(decrypted(text: "836fdf1bf0008e1be7b352d0ccd42dcb", secret: "deadbeefdeadbeef"))
    XCTAssertNil(decrypted(text: "8", secret: "deadbeefdeadbeefdeadbeefdeadbeef"))
    XCTAssertNil(decrypted(text: "83", secret: "deadbeefdeadbeefdeadbeefdeadbeef"))
    XCTAssertNil(decrypted(text: "asdf", secret: "deadbeefdeadbeefdeadbeefdeadbeef"))
  }

  func testDigest() {
    XCTAssertNotNil(digest(value: "ZNeX1idK+rOYKu9jcq7AS9+IBA3wuPWWZeUQchQrLIs=", secret: "deadbeef"))
  }
}
