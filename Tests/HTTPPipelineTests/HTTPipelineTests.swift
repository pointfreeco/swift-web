import XCTest
import Prelude
@testable import HTTPPipeline

class HTTPPipelineTests: XCTestCase {
  func testPipeline() {
//    let pipeline =
//      writeStatus(.ok)
//        >>> writeHeader(.contentType(.text))
//        >>> closeHeaders
//        >>> send("Hello, world")
//        >>> end
//
//    let request = URLRequest(url: URL(string: "/")!)
//    let conn = connection(from: request)
//    XCTAssertEqual("""
//Status 200
//Content-Type: application/text
//
//Hello, world
//""",
//                   pipeline(conn).response.description)
  }

  static var allTests = [
    ("testPipeline", testPipeline),
  ]
}
