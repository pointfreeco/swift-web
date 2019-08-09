import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest
import SnapshotTesting
import HttpPipelineTestSupport

class SyntaxRouterTests: XCTestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testHome() {
    let request = URLRequest(url: URL(string: "home")!)
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "get"
    let route = Routes.home

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual("home", router.templateUrl(for: route)?.absoluteString)
  }

  func testRoot() {
    let baseUrl = URL(string: "https://www.pointfree.co")!
    let request = URLRequest(url: baseUrl)
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "get"
    let route = Routes.root

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route, base: baseUrl))
    XCTAssertEqual("/", router.templateUrl(for: route)?.absoluteString)
    XCTAssertEqual("/", router.absoluteString(for: .root))
  }

  func testRequest_WithBaseUrl() {
    // BUG: https://bugs.swift.org/browse/SR-6407
    // NB: Previously we did `XCTAssertEqual` on a left/right side to check that the requests match, but
    //     due to a weird Swift bug (https://bugs.swift.org/browse/SR-6407) we are switching to a snapshot
    //     test.
    assertSnapshot(
      matching: router.request(for: .home, base: URL(string: "http://www.pointfree.co/"))!
        // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
        |> \.httpMethod .~ "GET",
      as: .raw
    )
  }

  func testAbsoluteString() {
    XCTAssertEqual("/home", router.absoluteString(for: .home))
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
    var request = URLRequest(url: URL(string: "signup")!)
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ "email=hello@pointfree.co".data(using: .utf8)

    XCTAssertNotNil(request.httpBody)
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
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(episode))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: route))
  }

  func testSimpleQueryParams() {
    let request = URLRequest(url: URL(string: "path/to/somewhere/cool?ref=hello&active=true&t=122")!)
      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
      |> \.httpMethod .~ "get"
    let route = Routes.simpleQueryParams(ref: "hello", active: true, t: 122)

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual(
      "path/to/somewhere/cool?ref=:optional_string&active=:bool&t=:int",
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
      "path/to/somewhere/cool?ref=:optional_string&active=:bool&t=:int",
      router.templateUrl(for: route)?.absoluteString
    )
  }

//  func testCodableQueryParams() {
//    let request = URLRequest(url: URL(string: "subscribe?plan=1")!)
//      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
//      |> \.httpMethod .~ "get"
//    let route = Routes.codableQueryParams(SubscribeData(plan: 1))
//
//    XCTAssertEqual(route, router.match(request: request))
//    XCTAssertEqual(request, router.request(for: route))
//    #if os(Linux)
//      XCTAssertEqual(
//        "subscribe?plan=:int",
//        router.templateUrl(for: route)?.absoluteString
//      )
//    #else
//      XCTAssertEqual(
//        "subscribe?plan=:__nscfnumber", // FIXME
//        router.templateUrl(for: route)?.absoluteString
//      )
//    #endif
//  }
//
  // FIXME: Make work!
//  func testCodableQueryParamsOptionality() {
//    let request = URLRequest(url: URL(string: "subscribe")!)
//      // NB: necessary for linux tests: https://bugs.swift.org/browse/SR-6405
//      |> \.httpMethod .~ "get"
//    let route = Routes.codableQueryParams(nil)
//
//    XCTAssertEqual(route, router.match(request: request))
//    XCTAssertEqual(request, router.request(for: route))
//  }

  func testCodableFormDataPostBody() {
    var request = URLRequest(url: URL(string: "subscribe")!)
    request.httpMethod = "post"
    request.httpBody = Data("plan=1&quantity=2".utf8)
    let route = Routes.postBodyFormData(SubscribeData(plan: 1, quantity: 2))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: route))
    XCTAssertEqual(
      "subscribe",
      router.templateUrl(for: route)?.absoluteString
    )
    assertSnapshot(
      matching: router.request(for: .postBodyFormData(SubscribeData(plan: 2, quantity: 3)))!,
      as: .raw
    )
  }

  func testRedirect() {
    XCTAssertEqual(
      "/somewhere?redirect=http://localhost:8080/home?redirect%3Dhttp://localhost:8080/home",
      router.absoluteString(for: .redirect("http://localhost:8080/home?redirect=http://localhost:8080/home"))
    )
  }
}
