import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import XCTest

class HttpPipelineHtmlSupportTests: XCTestCase {
  func testResponse() {
    let view = View<Prelude.Unit>(const(pure(p(["Hello world!"]))))
    let pipeline = writeStatus(.ok)
      >-> respond(view)

    let conn = connection(from: URLRequest(url: URL(string: "/")!))
    let response = (conn |> pipeline).perform()

    XCTAssertEqual(200, response.response.status.rawValue)
    XCTAssertEqual(
      ["Content-Type: text/html; charset=utf-8", "Content-Length: 19"],
      response.response.headers.map(^\.description)
    )
    XCTAssertEqual("<p>Hello world!</p>", String(decoding: response.response.body, as: UTF8.self))
  }
}
