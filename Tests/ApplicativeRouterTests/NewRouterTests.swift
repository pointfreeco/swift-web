@testable import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest

class NewRouterTests: XCTestCase {
  func testRouter() {

    let homeRouter = Routes.iso.home <¢> lit("home") <* _end

    let postCommentRouter = (flatten() >>> Routes.iso.postComment)
      <¢> (
        (lit("posts") *> str("post_id"))
          <*> (lit("comments") *> int("comment_id"))
          <*> param("ref")
          <* _end
    )

    let postCommentsRouter = Routes.iso.postComments
      <¢> (
        (lit("posts") *> str("post_id"))
          <* lit("comments")
          <* _end
    )

    let router = [
      homeRouter,
      postCommentRouter,
      postCommentsRouter,
      ]
      .reduce(.empty, <|>)

    XCTAssertEqual(
      .postComment("hello-world", 42, "twitter"),
      router.match(URLRequest(url: URL(string: "http://www.site.com/posts/hello-world/comments/42?ref=twitter")!))
    )
    XCTAssertEqual(
      "posts/hello-world/comments/42?ref=twitter",
      router.print(.postComment("hello-world", 42, "twitter"))?.url?.absoluteString
    )

    XCTAssertEqual(
      .home(unit),
      router.match(URLRequest(url: URL(string: "http://www.site.com/home")!))
    )
    XCTAssertEqual(
      "home",
      router.print(.home(unit))?.url?.path
    )

    XCTAssertEqual(
      .postComments("hello-world"),
      router.match(URLRequest(url: URL(string: "http://www.site.com/posts/hello-world/comments")!))
    )
    XCTAssertEqual(
      "posts/hello-world/comments",
      router.print(.postComments("hello-world"))?.url?.path
    )
  }
}

enum Routes: Equatable {
  case home(Prelude.Unit)
  case posts
  case post(String)
  case postComments(String)
  case postComment(String, Int, String)

  enum iso {
    static let postComment = Iso<(String, Int, String), Routes>(
      image: Routes.postComment,
      preimage: {
        guard case let .postComment(route) = $0 else { return nil }
        return route
    })

    static let home = Iso<Prelude.Unit, Routes>(
      image: Routes.home,
      preimage: {
        guard case let .home(route) = $0 else { return nil }
        return route
    })

    static let postComments = Iso<String, Routes>(
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
      return lhs == rhs

    case (.home, _), (.post, _), (.posts, _), (.postComments, _), (.postComment, _):
      return false
    }
  }
}
