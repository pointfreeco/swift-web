import ApplicativeRouter
import Css
import CssReset
import Foundation
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import HttpPipeline
import HttpPipelineTestSupport
import Prelude

/*:
 ## Html
 */

let document = html(
  [
    body(
      [
        p(["Hello world!"]),
        p(["Goodbye!"]),
        a([href("/")], ["Home"])
      ]
    )
  ]
)

print(render(document, config: pretty))

/*:
 ## Css
 */

let css = body % (
  padding(all: .rem(2))
    <> background(Color.hsl(60, 0.5, 0.8))
)

print(render(css: css))

/*:
 ## HttpPipeline
 */

let middleware = writeStatus(.ok)
  >>> writeHeader(.contentType(.html))
  >>> closeHeaders
  >>> send(render(document).data(using: .utf8))
  >>> end

let request = URLRequest(url: URL(string: "/")!)
let conn = connection(from: request).map(const(Data?.none))

print(middleware(conn).snapshotFormat)

/*:
 ## ApplicativeRouter
 */

struct UserData: Decodable {
  let email: String
}

enum Route {
  case home
  case episodes
  case episode(String)
  case search(String?)
  case signup(UserData?)
}

let router =
  // Matches: GET /
  Route.home <¢ .get <*| end
    // Matches: GET /episode/:str
    <|> Route.episode <¢> (.get *> lit("episode") *> .str) <*| end
    // Matches: GET /episodes
    <|> Route.episodes <¢ (.get *> lit("episodes")) <*| end
    // Matches: GET /search?query=
    <|> Route.search <¢> (.get *> lit("search") *> opt(param("query"))) <*| end
    // Matches: POST /signup
    <|> Route.signup <¢> (.post *> lit("signup") *> opt(.jsonBody)) <*| end

let requestToRoute = URLRequest(url: URL(string: "http://localhost:8000/episode/001-hello-world")!)
let route = router.match(requestToRoute)

dump(route!)

/*:
 ## HtmlCssSupport
 */

let anchorStyle = color(.red)
  <> textTransform(.capitalize)

let styledDocument = p(
  [
    "Go back ",
    a([style(anchorStyle)], ["Home"])
  ]
)
print(render(styledDocument, config: pretty))

/*:
 ## HtmlPrettyPrint
 */

let prettyDoc: Node = .document(
  [
    html(
      [
        body(
          [
            comment("This is gonna be a long comment. Let's see what happens!"),
            div(
              [
                div([ id("some-long-id"), Html.class("foo bar baz") ], ["hello world"]),
                img(src: "cat.jpg", alt: "", [ id("cat"), Html.class("cat") ])
              ]
            )
          ]
        )
      ]
    )
  ]
)

print(prettyPrint(node: prettyDoc, pageWidth: 40))

/*:
 ## CssReset
 */

print(render(config: pretty, css: reset))
