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
    let route = Routes.pathComponents(param: .right(42), commentId: 2)

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual(
      "home/episodes/:string_or_int/comments/:int",
      router.templateUrl(for: route)?.absoluteString
    )
  }

  func testPathComponents_StringParam() {
    let request = URLRequest(url: URL(string: "home/episodes/hello-world/comments/2")!)
    let route = Routes.pathComponents(param: .left("hello-world"), commentId: 2)

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual(
      "home/episodes/:string_or_int/comments/:int",
      router.templateUrl(for: route)?.absoluteString
    )
  }

  func testPostBodyField() {
    let route = Routes.postBodyField(email: "hello@pointfree.co")
    let request = URLRequest(url: URL(string: "signup")!)
      |> \.httpBody .~ Data("email=hello@pointfree.co".utf8)
      |> \.httpMethod .~ "POST"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual("signup", router.templateUrl(for: route)?.absoluteString)
  }

  func testPostBodyJsonDecodable() {
    let episode = Episode(
      title: "Intro to Functions", blurb: "Everything about functions!", length: 300, category: nil
    )
    let route = Routes.postBodyJsonDecodable(episode: episode, param: 42)
    let request = URLRequest(url: URL(string: "episodes/42")!)
      |> \.httpBody .~ (try? JSONEncoder().encode(episode))
      |> \.httpMethod .~ "POST"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
  }

  func testSimpleQueryParams() {
    let request = URLRequest(url: URL(string: "path/to/somewhere/cool?active=true&ref=hello&t=122")!)
    let route = Routes.simpleQueryParams(ref: "hello", active: true, t: 122)

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual(
      "path/to/somewhere/cool?active=:bool&ref=:optional_string&t=:int",
      router.templateUrl(for: route)?.absoluteString
    )
  }
}
