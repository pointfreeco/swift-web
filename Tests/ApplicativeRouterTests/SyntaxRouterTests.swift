import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest

import Foundation

//func XCTAssertRequestEqual(_ lhs: URLRequest, _ rhs: URLRequest) {
//
//}

class SyntaxRouterTests: XCTestCase {
  func testRoot() {
    let request = URLRequest(url: URL(string: "home")!)
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "get"
    let route = Routes.root

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route)!)
    XCTAssertEqual("home", router.templateUrl(for: route)?.absoluteString)
  }

  func testRequest_WithBaseUrl() {
    var lhs = URLRequest(url: URL(string: "http://www.pointfree.co/home")!)
    //lhs.httpMethod = "get"

    let rhs = router.request(for: .root, base: URL(string: "http://www.pointfree.co/"))!

    //dump(lhs) // comment this out and the test will fail.

    XCTAssertEqual(lhs, rhs)
  }

  func testAbsoluteString() {
    XCTAssertEqual("/home", router.absoluteString(for: .root))
    XCTAssertEqual(
      "/home/episodes/intro-to-functions/comments/42",
      router.absoluteString(for: .pathComponents(param: .left("intro-to-functions"), commentId: 42))
    )
  }

  func testLitFails() {
    let request = URLRequest(url: URL(string: "foo")!)

    XCTAssertNil(router.match(request: request))
  }

  func testPathComponents_IntParam() {
    let request = URLRequest(url: URL(string: "home/episodes/42/comments/2")!)
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "get"
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
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "get"
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
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "post"

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
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "post"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
  }

  func testSimpleQueryParams() {
    let request = URLRequest(url: URL(string: "path/to/somewhere/cool?active=true&ref=hello&t=122")!)
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "get"
    let route = Routes.simpleQueryParams(ref: "hello", active: true, t: 122)

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual(
      "path/to/somewhere/cool?active=:bool&ref=:optional_string&t=:int",
      router.templateUrl(for: route)?.absoluteString
    )
  }

  func testSimpleQueryParams_SomeMissing() {
    let request = URLRequest(url: URL(string: "path/to/somewhere/cool?active=true&t=122")!)
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "get"
    let route = Routes.simpleQueryParams(ref: nil, active: true, t: 122)

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual(
      "path/to/somewhere/cool?active=:bool&ref=:optional_string&t=:int",
      router.templateUrl(for: route)?.absoluteString
    )
  }
}
