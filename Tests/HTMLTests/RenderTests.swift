import XCTest
import Prelude
import HTML
import CSS

class RenderTests: XCTestCase {
  func renderMonoidMorphism() {
    let a = span(["a"])
    let b = span(["b"])

    XCTAssertEqual(render([a] <> [b]), render(a) <> render(b))
  }
}
