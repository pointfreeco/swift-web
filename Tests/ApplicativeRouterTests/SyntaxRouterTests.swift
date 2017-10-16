import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest

class SyntaxRouterTests: XCTestCase {
  func testRoot() {
    let request = URLRequest(url: URL(string: "home")!)
    let route = Routes.root

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual("home", router.templateUrl(for: route)?.absoluteString)
  }

  func testPathComponents_IntParam() {
    let request = URLRequest(url: URL(string: "home/episodes/42/comments/2")!)
    let route = Routes.pathComponents(episodeParam: .right(42), commentId: 2)

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual(
      "home/episodes/:string_or_int/comments/:int",
      router.templateUrl(for: route)?.absoluteString
    )
  }

  func testPathComponents_StringParam() {
    let request = URLRequest(url: URL(string: "home/episodes/hello-world/comments/2")!)
    let route = Routes.pathComponents(episodeParam: .left("hello-world"), commentId: 2)

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
  }
}
