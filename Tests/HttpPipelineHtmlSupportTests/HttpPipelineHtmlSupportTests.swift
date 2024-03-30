#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import View
import XCTest

class HttpPipelineHtmlSupportTests: XCTestCase {
  @MainActor
  func testResponse() async {
    let view = View<Prelude.Unit> { _ in .p(["Hello world!"]) }
    let pipeline = writeStatus(.ok)
      >=> respond(view)

    let conn = connection(from: URLRequest(url: URL(string: "/")!), defaultHeaders: [:])
    let response = await (conn |> pipeline).performAsync()

    XCTAssertEqual(200, response.response.status.code)
    XCTAssertEqual(
      ["Content-Type: text/html; charset=utf-8", "Content-Length: 19"],
      response.response.headers.map(^\.description)
    )
    XCTAssertEqual("<p>Hello world!</p>", String(decoding: response.response.body, as: UTF8.self))
  }
}
