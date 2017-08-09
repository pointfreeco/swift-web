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
    let router =
      Route.home <¢ .get <*| end
        <|> Route.episode <¢> (.get <* lit("episode") *> .str) <*| end
        <|> Route.episodes <¢ (.get <* lit("episodes")) <*| end
        <|> Route.search <¢> (.get <* lit("search") *> opt(param("query"))) <*| end
        <|> Route.signup <¢> (.post *> .dataBody) <* lit("signup") <*| end

    XCTAssertEqual(router.match(req(.get, "/")), .home)
    XCTAssertEqual(router.match(req(.get, "/episodes")), .episodes)
    XCTAssertEqual(router.match(req(.get, "/episodes/")), .episodes)
    XCTAssertEqual(router.match(req(.get, "/episodes//")), .episodes)
    XCTAssertEqual(router.match(req(.get, "/episode/hello-world")), .episode("hello-world"))
    XCTAssertEqual(router.match(req(.get, "/search")), .search(nil))
    XCTAssertEqual(router.match(req(.get, "/search?query=what")), .search("what"))
    XCTAssertNil(router.match(req(.get, "/not-found")))
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
}

enum Route {
  case home
  case episodes
  case episode(String)
  case search(String?)
  case signup(Data)
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
