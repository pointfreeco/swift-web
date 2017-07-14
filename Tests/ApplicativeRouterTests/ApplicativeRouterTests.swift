import ApplicativeRouter
import Prelude
import XCTest

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

let req = { (method: ApplicativeRouter.Method, location: String) in
  URLRequest(url: URL(string: location)!)
    |> (set(\URLRequest.httpMethod) <| method.rawValue.uppercased())
}

class ApplicativeRouterTests: XCTestCase {
  func testRouter() {
    let router =
      Route.home <¢ get <* end
        <|> Route.episode <¢> (get <* lit("episode") *> str) <* end
        <|> Route.episodes <¢ (get <* lit("episodes")) <* end
        <|> Route.search <¢> (get <* lit("search") *> opt(param("query"))) <* end

    XCTAssertEqual(router.match(req(.get, "/")), .home)
    XCTAssertEqual(router.match(req(.get, "/episodes")), .episodes)
    XCTAssertEqual(router.match(req(.get, "/episodes/")), .episodes)
    XCTAssertEqual(router.match(req(.get, "/episodes//")), .episodes)
    XCTAssertEqual(router.match(req(.get, "/episode/hello-world")), .episode("hello-world"))
    XCTAssertEqual(router.match(req(.get, "/search")), .search(nil))
    XCTAssertEqual(router.match(req(.get, "/search?query=what")), .search("what"))
    XCTAssertNil(router.match(req(.get, "/not-found")))
  }

  static var allTests = [
    ("testRouter", testRouter),
  ]
}
