import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import XCTest

class HttpPipelineHtmlSupportTests: XCTestCase {
  func testResponse() {
    let view = View<Prelude.Unit> { _ in p(["Hello world!"]) }
    let pipeline = writeStatus(.ok)
      >>> respond(view)
    let conn = connection(from: URLRequest(url: URL(string: "/")!))
    let response = conn |> pipeline

    XCTAssertEqual(200, response.response.status.rawValue)
    XCTAssertEqual(
      "Content-Type: text/html; charset=utf8",
      response.response.headers.map { $0.description }.joined(separator: "")
    )
    XCTAssertEqual("<p>Hello world!</p>", String(data: response.response.body!, encoding: .utf8))
  }
}
