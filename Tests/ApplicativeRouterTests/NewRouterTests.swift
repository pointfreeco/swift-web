@testable import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest

class NewRouterTests: XCTestCase {
  func testRouter() {
    let router = [
      curry(Routes.iso.home)
        <¢> lit("home") <% _end,

      curry(Routes.iso.postComments)
        <¢> lit("posts") %> .str <% lit("comments") <% _end,

      curry(Routes.iso.postComment)
        <¢> lit("posts") %> .str
        <%> lit("comments") %> .int
        <%> param("ref", Optional.iso.some)
        <%> param("active", boolStringIso)
        <% _end,
      ]
      .reduce(.empty, <|>)

    let postCommentRoute = Routes.postComment(slug: "", commentId: 0, ref: "", active: true)

    XCTAssertEqual(
      .postComment(slug: "hello-world", commentId: 42, ref: "twitter", active: true),
      router.match(URLRequest(url: URL(string: "/posts/hello-world/comments/42?ref=twitter&active=true")!))
    )
    XCTAssertEqual(
      "posts/hello-world/comments/42?ref=twitter&active=false",
      router.request(for: postCommentRoute)?.url?.absoluteString
    )
    XCTAssertEqual(
      "posts/:string/comments/:int?ref=:optional_string&active=:bool",
      router.templateRequest(for: postCommentRoute)?.url?.absoluteString
    )

    XCTAssertEqual(
      .home(unit),
      router.match(URLRequest(url: URL(string: "http://www.site.com/home")!))
    )
    XCTAssertEqual(
      "home",
      router.request(for: .home(unit))?.url?.path
    )

    XCTAssertEqual(
      .postComments("hello-world"),
      router.match(URLRequest(url: URL(string: "http://www.site.com/posts/hello-world/comments")!))
    )
    XCTAssertEqual(
      "posts/hello-world/comments",
      router.request(for: .postComments("hello-world"))?.url?.path
    )
  }
}

enum Routes: Equatable {
  case home(Prelude.Unit)
  case posts
  case post(String)
  case postComments(String)
  case postComment(slug: String, commentId: Int, ref: String?, active: Bool)

  enum iso {
    static let postComment = PartialIso<(String, Int, String?, Bool), Routes>(
      image: Routes.postComment,
      preimage: {
        guard case let .postComment(route) = $0 else { return nil }
        return route
    })

    static let home = PartialIso<Prelude.Unit, Routes>(
      image: Routes.home,
      preimage: {
        guard case let .home(route) = $0 else { return nil }
        return route
    })

    static let postComments = PartialIso<String, Routes>(
      image: Routes.postComments,
      preimage: {
        guard case let .postComments(route) = $0 else { return nil }
        return route
    })
  }

  static func == (lhs: Routes, rhs: Routes) -> Bool {
    switch (lhs, rhs) {
    case let (.home(lhs), .home(rhs)):
      return lhs == rhs
    case (.posts, .posts):
      return true
    case let (.post(lhs), .post(rhs)):
      return lhs == rhs
    case let (.postComments(lhs), .postComments(rhs)):
      return lhs == rhs
    case let (.postComment(lhs), .postComment(rhs)):
      return lhs.0 == rhs.0 && lhs.1 == rhs.1 && lhs.2 == rhs.2 && lhs.3 == rhs.3

    case (.home, _), (.post, _), (.posts, _), (.postComments, _), (.postComment, _):
      return false
    }
  }
}
