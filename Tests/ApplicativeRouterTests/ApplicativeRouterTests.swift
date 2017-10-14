import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest

func req(_ method: ApplicativeRouter.Method, _ location: String, _ body: Data? = nil) -> URLRequest {
  return URLRequest(url: URL(string: location)!)
    |> \.httpMethod .~ method.rawValue.uppercased()
    |> \.httpBody .~ body
}

class ApplicativeRouterTests: XCTestCase {
  func testRouter() {

    let tmp = Route.home <¢ .get

    let routes: [Parser<(), Route>] = [
      // Matches root path: /
      Route.home <¢ .get <*| end,

      // Route with path argument and two optional query params: /episode/:id?ref=foo&t=123
      curry(Route.episode) <¢ .get <*> (lit("episode") *> .str) <*> opt(param("ref")) <*> opt(param("t", .int)) <*| end,

      // Route with multiple path arguments: /episodes/:slug/comments/:id
      curry(Route.episodeComment) <¢ .get <* lit("episodes") <*> .str <* lit("comments") <*> .int <*| end,

      // Route with no path arguments and two query params, `page` and `ref`. However, the `ref` param
      // is parsed using the `refTag` helper that will provide a first class wrapper type for that value.
      Route.episodes <¢> refTag(.get <* lit("episodes") *> opt(param("page", .int))) <*| end,

      // Route with one query param: /search?query=foo
      Route.search <¢ .get <* lit("search") <*> opt(param("query")) <*| end,

      // POST route with body data and an optional query param.
      curry(Route.signup) <¢> (.post *> .dataBody) <* lit("signup") <*> opt(param("ref")) <*| end,
    ]

    let router = routes.reduce(.empty, <|>)

    XCTAssertEqual(router.match(req(.get, "/")), .home)
    XCTAssertEqual(router.match(req(.get, "/episodes")), Route.episodes(RefTag(ref: nil, rest: nil)))
    XCTAssertEqual(router.match(req(.get, "/episodes/")), Route.episodes(RefTag(ref: nil, rest: nil)))
    XCTAssertEqual(router.match(req(.get, "/episodes//")), Route.episodes(RefTag(ref: nil, rest: nil)))
    XCTAssertEqual(
      router.match(req(.get, "/episodes?ref=home")),
      .episodes(RefTag(ref: "home", rest: nil))
    )
    XCTAssertEqual(
      router.match(req(.get, "/episodes?ref=home&page=2")),
      .episodes(RefTag(ref: "home", rest: 2))
    )
    XCTAssertEqual(
      router.match(req(.get, "/episode/hello-world")),
      .episode(id: "hello-world", ref: nil, startAt: nil)
    )
    XCTAssertEqual(
      router.match(req(.get, "/episode/hello-world?ref=twitter")),
      .episode(id: "hello-world", ref: "twitter", startAt: nil)
    )
    XCTAssertEqual(
      router.match(req(.get, "/episode/hello-world?ref=twitter&t=1234")),
      .episode(id: "hello-world", ref: "twitter", startAt: 1234)
    )
    XCTAssertEqual(
      router.match(req(.get, "/episodes/hello-world/comments/42")),
      .episodeComment(episodeSlug: "hello-world", commentId: 42)
    )
    XCTAssertEqual(router.match(req(.get, "/search")), .search(nil))
    XCTAssertEqual(router.match(req(.get, "/search?query=what")), .search("what"))
    XCTAssertNil(router.match(req(.get, "/not-found")))
    XCTAssertEqual(
      .signup(Data("email=hi@pointfree.co".utf8), ref: nil),
      router.match(req(.post, "/signup", Data("email=hi@pointfree.co".utf8)))
    )
    XCTAssertEqual(
      .signup(Data("email=hi@pointfree.co".utf8), ref: "subscribe"),
      router.match(req(.post, "/signup?ref=subscribe", Data("email=hi@pointfree.co".utf8)))
    )
  }

  func testPostData() {
    let router =
      PostTestRoute.postData <¢> (.post *> .dataBody) <* lit("post") <*| end
        <|> PostTestRoute.postString <¢> (.post *> .stringBody) <* lit("post") <*| end

    XCTAssertNil(router.match(req(.post, "/post", nil)))

    let helloData = "hello".data(using: .utf8)!
    XCTAssertEqual(.postData(helloData), router.match(req(.post, "/post", helloData)))
  }

  func testPostString() {
    let router =
      PostTestRoute.postString <¢> (.post *> .stringBody) <* lit("post") <*| end

    XCTAssertNil(router.match(req(.post, "/post", nil)))

    let hello = "hello"
    let helloData = hello.data(using: .utf8)!
    XCTAssertEqual(.postString(hello), router.match(req(.post, "/post", helloData)))
  }

  func testPostJsonBody() {
    let router =
      PostTestRoute.postUser <¢> (.post *> either(.jsonBody, pure("Invalid JSON"))) <* lit("post") <*| end

    XCTAssertEqual(.postUser(.right("Invalid JSON")), router.match(req(.post, "/post", nil)))

    let userData = "{\"id\":1}".data(using: .utf8)!
    XCTAssertEqual(.postUser(.left(.init(id: 1))), router.match(req(.post, "/post", userData)))
  }

  func testFormData() {
    let router =
      PostTestRoute.postFormData <¢> (.post *> .formData) <* lit("post") <*| end

    let formString = "email=hello%40pointfree.co"
    let formData = formString.data(using: .utf8)!
    XCTAssertEqual(.postFormData(["email": "hello@pointfree.co"]),
                   router.match(req(.post, "/post", formData)))
  }

  func testFormField() {
    let router =
      PostTestRoute.postString <¢> (.post *> .formField("email")) <* lit("post") <*| end

    let formString = "email=hello%40pointfree.co"
    let formData = formString.data(using: .utf8)!
    XCTAssertEqual(.postString("hello@pointfree.co"), router.match(req(.post, "/post", formData)))
  }

  func testFormFieldParser() {
    let router =
      PostTestRoute.postInt <¢> (.post *> .formField("page", .int)) <* lit("post") <*| end

    let formString = "page=50"
    let formData = formString.data(using: .utf8)!
    XCTAssertEqual(.postInt(50), router.match(req(.post, "/post", formData)))
  }

  func testMissingFormFieldValue() {
    let router =
      PostTestRoute.postString <¢> (.post *> .formField("email")) <* lit("post") <*| end

    let formString = "email="
    let formData = formString.data(using: .utf8)!
    XCTAssertEqual(.postString(""), router.match(req(.post, "/post", formData)))
  }

  func testMissingData() {
    let router =
      PostTestRoute.postString <¢> (.post *> .formField("email")) <* lit("post") <*| end

    let formString = ""
    let formData = formString.data(using: .utf8)!
    XCTAssertNil(router.match(req(.post, "/post", formData)))
  }
}

enum Route {
  case home
  case episode(id: String, ref: String?, startAt: Int?)
  case episodeComment(episodeSlug: String, commentId: Int)
  case episodes(RefTag<Int?>)
  case search(String?)
  case signup(Data, ref: String?)
}

extension Route: Equatable {
  static func == (lhs: Route, rhs: Route) -> Bool {
    switch (lhs, rhs) {
    case (.home, .home):
      return true

    case let (.episode(lhsId, lhsRef, lhsStartAt), .episode(rhsId, rhsRef, rhsStartAt)):
      return lhsId == rhsId && lhsRef == rhsRef && lhsStartAt == rhsStartAt

    case let (.episodeComment(lhs), .episodeComment(rhs)):
      return lhs == rhs

    case let (.episodes(lhs), .episodes(rhs)):
      return lhs.ref == rhs.ref && lhs.rest == rhs.rest

    case let (.search(l), .search(r)):
      return l == r

    case let (.signup(lhsData, lhsRef), .signup(rhsData, rhsRef)):
      return lhsData == rhsData && lhsRef == rhsRef

    case (.home, _), (.episode, _), (.episodeComment, _), (.episodes, _), (.search, _), (.signup, _):
      return false
    }
  }
}

struct User: Decodable {
  let id: Int
}

enum PostTestRoute: Equatable {
  case postData(Data)
  case postFormData([String: String])
  case postInt(Int)
  case postString(String)
  case postUser(Either<User, String>)

  static func == (lhs: PostTestRoute, rhs: PostTestRoute) -> Bool {
    switch (lhs, rhs) {
    case let (.postData(lhs), .postData(rhs)):
      return lhs == rhs
    case let (.postFormData(lhs), .postFormData(rhs)):
      return lhs == rhs
    case let (.postInt(lhs), .postInt(rhs)):
      return lhs == rhs
    case let (.postString(lhs), .postString(rhs)):
      return lhs == rhs
    case let (.postUser(.left(lhs)), .postUser(.left(rhs))):
      return lhs.id == rhs.id
    case let (.postUser(.right(lhs)), .postUser(.right(rhs))):
      return lhs == rhs
    default:
      return false
    }
  }
}

/// A struct that holds a ref tag that can be plucked from a query string, along with whatever else
/// could get plucked from the request.
struct RefTag<A> {
  let ref: String?
  let rest: A
}

/// Converts a parser of `A` into a parser of `RefTag<A>` by first trying to parse out the `A`, and then
/// parsing a query param `ref` and storing both values in `RefTag<A>`.
func refTag<I, A>(_ parser: Parser<I, A>) -> Parser<I, RefTag<A>> {

  return curry(RefTag<A>.init)
    <¢> opt(param("ref"))
    <*> parser
}
