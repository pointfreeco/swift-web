import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import XCTest

class SupportTests: XCTestCase {
  func testResponse() {
    let view = View<Prelude.Unit> { _ in p(["Hello world!"]) }
    let pipeline = writeStatus(.ok)
      >>> respond(view)
    let conn = connection(from: URLRequest(url: URL(string: "/")!))
    let response = conn |> pipeline

    XCTAssertEqual(200, response.response.status.rawValue)
    XCTAssertEqual(
      "Content-Type: text/html",
      response.response.headers.map { $0.description }.joined(separator: "")
    )
    XCTAssertEqual("<p>Hello world!</p>", response.response.body)
  }
}
