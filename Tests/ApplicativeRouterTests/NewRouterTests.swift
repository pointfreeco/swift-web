import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest

infix operator <&>
infix operator <?>
infix operator <^>
infix operator </>

class NewRouterTests: XCTestCase {
  func testRouter() {

    let router = [
      Routes.iso.home
        <¢> lit("home")
        %> queryParams(Routes.HomeData.self)
        <% _end,

      Routes.iso.postComments
        <¢> get %> lit("posts") %> .str <% lit("comments")
        <% _end,

      Routes.iso.postComments
        <¢> post %> lit("posts") %> .str <% lit("comments")
        <% _end,

      Routes.iso.postComment
        <¢> get %> lit("posts") %> .str <%> lit("comments") %> .int
        <%> "ref" <=> opt(.str)
        <%> "active" <=> .bool
        <% _end,
      ]
      .reduce(.empty, <|>)

    let postCommentRoute = Routes.postComment(slug: "hello-world", commentId: 42, ref: "twitter", active: true)

    XCTAssertEqual(
      postCommentRoute,
      router.match(url: URL(string: "/posts/hello-world/comments/42?ref=twitter&active=true")!)
    )
    XCTAssertEqual(
      "posts/hello-world/comments/42?ref=twitter&active=true",
      router.url(for: postCommentRoute)?.absoluteString
    )
    XCTAssertEqual(
      "posts/:string/comments/:int?ref=:optional_string&active=:bool",
      router.templateUrl(for: postCommentRoute)?.absoluteString
    )

    XCTAssertEqual(
      .home(.init(x: "foo", y: "bar", z: "blob")),
      router.match(url: URL(string: "http://www.site.com/home?x=foo&y=bar&z=blob")!)
    )
    XCTAssertEqual(
      "home?y=bar&x=foo&z=blob",
      router.url(for: .home(.init(x: "foo", y: "bar", z: "blob")))?.absoluteString
    )
    XCTAssertEqual(
      "home?y=:string&x=:string&z=:string",
      router.templateUrl(for: .home(.init(x: "", y: "", z: "")))?.absoluteString
    )

    XCTAssertEqual(
      .postComments("hello-world"),
      router.match(url: URL(string: "http://www.site.com/posts/hello-world/comments")!)
    )
    XCTAssertEqual(
      "posts/hello-world/comments",
      router.url(for: .postComments("hello-world"))?.path
    )
  }
}

enum Routes: Equatable {
  case home(HomeData)
  case postComments(String)
  case postComment(slug: String, commentId: Int, ref: String?, active: Bool)

  struct HomeData: Codable, Equatable {
    let x: String
    let y: String
    let z: String

    static func ==(lhs: Routes.HomeData, rhs: Routes.HomeData) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
  }

  enum iso {
    static let postComment = parenthesize <| PartialIso<(String, Int, String?, Bool), Routes>(
      image: Routes.postComment,
      preimage: {
        guard case let .postComment(route) = $0 else { return nil }
        return route
    })

    static let home = parenthesize <| PartialIso<HomeData, Routes>(
      image: Routes.home,
      preimage: {
        guard case let .home(route) = $0 else { return nil }
        return route
    })

    static let postComments = parenthesize <| PartialIso<String, Routes>(
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
    case let (.postComments(lhs), .postComments(rhs)):
      return lhs == rhs
    case let (.postComment(lhs), .postComment(rhs)):
      return lhs.0 == rhs.0 && lhs.1 == rhs.1 && lhs.2 == rhs.2 && lhs.3 == rhs.3

    case (.home, _), (.postComments, _), (.postComment, _):
      return false
    }
  }
}
