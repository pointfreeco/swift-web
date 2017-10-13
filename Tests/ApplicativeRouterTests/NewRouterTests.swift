@testable import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest

class NewRouterTests: XCTestCase {
  func testRouter() {

    let homeRouter = Routes.iso.home <¢> lit("home") <* _end

    let postCommentRouter = Routes.iso.postComment
      <¢> (
        (lit("posts") *> str("post_id"))
          <*> (lit("comments") *> int("comment_id"))
          <* _end
    )

    let postCommentsRouter = Routes.iso.postComments
      <¢> (
        (lit("posts") *> str("post_id"))
//          <* lit("comments")
//          <* _end
    )

    let router = [
      homeRouter,
//      postCommentRouter,
//      postCommentsRouter,
      ]
      .reduce(Router<Routes>.empty, <|>)

    print(router.match(URLRequest(url: URL(string: "http://www.site.com/posts/hello-world/comments/42")!)))
    print(router.print(.postComment("hello-world", 42)))


    print(router.match(URLRequest(url: URL(string: "http://www.site.com/home")!)))
    print(router.print(.home(unit)))

    print("")
  }
}

enum Routes {
  case home(Prelude.Unit)
  case posts
  case post(String)
  case postComments(String)
  case postComment(String, Int)

  enum iso {
    static let postComment = Iso<(String, Int), Routes>(
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
}
