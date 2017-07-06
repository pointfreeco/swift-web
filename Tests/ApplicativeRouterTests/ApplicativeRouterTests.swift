import XCTest
import Prelude
@testable import ApplicativeRouter

enum Route {
  case home
  case episodes
  case episode(String)
  case search(String?)
}

extension Route: Equatable {
  static func == (lhs: Route, rhs: Route) -> Bool {
    switch (lhs, rhs) {
    case (.home, .home):
      return true
    case (.episodes, .episodes):
      return true
    case let (.episode(l), .episode(r)):
      return l == r
    case let (.search(l), .search(r)):
      return l == r
    default:
      return false
    }
  }
}

let req = { loc in URLRequest(url: URL(string: loc)!) }

class ApplicativeRouterTests: XCTestCase {
  func testRouter() {
    let router =
      Route.home <¢ end
        <|> Route.episode <¢> (lit("episode") *> str) <* end
        <|> Route.episodes <¢ (lit("episodes")) <* end
        <|> Route.search <¢> (lit("search") *> opt(param("query"))) <* end

    XCTAssertEqual(router.match(req("/")), .home)
    XCTAssertEqual(router.match(req("/episodes")), .episodes)
    XCTAssertEqual(router.match(req("/episodes/")), .episodes)
    XCTAssertEqual(router.match(req("/episodes//")), .episodes)
    XCTAssertEqual(router.match(req("/episode/hello-world")), .episode("hello-world"))
    XCTAssertEqual(router.match(req("/search")), .search(nil))
    XCTAssertEqual(router.match(req("/search?query=what")), .search("what"))
    XCTAssertNil(router.match(req("/not-found")))
  }

  static var allTests = [
    ("testRouter", testRouter),
  ]
}
