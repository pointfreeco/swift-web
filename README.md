# swift-web [![CircleCI](https://circleci.com/gh/pointfreeco/swift-web.svg?style=svg)](https://circleci.com/gh/pointfreeco/swift-web)

A collection of frameworks for solving various problems in building a Swift web framework. Each framework focuses on a single problem, like HTML rendering, CSS preprocessing, routing, middleware, and more. They also do not depend on any other framework in the collection. You can choose which pieces you want and don't want, for example you can use `Html` without `Css`.

## Stability

This library should be considered alpha, and not stable. Breaking changes will happen often.

## Installation

```swift
import PackageDescription

let package = Package(
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-web.git", .branch("master")),
  ]
)
```

## Getting started

This library contains an extensive test suite and a set of playgrounds that can be explored. To get it running:

* `git clone https://github.com/pointfreeco/swift-web.git`
* `cd swift-web`
* `swift package generate-xcodeproj`
* `xed .`
* Run tests: Command+U
* Build: Command+B
* Open a playground!

## Included modules

#### Primary modules

* [`Html`](#html)
* [`Css`](#css)
* [`HttpPipeline`](#httppipeline)
* [`ApplicativeRouter`](#applicativerouter)

#### Supporting modules

* [`HttpPipelineHtmlSupport`](#httppipelinehtmlsupport)
* [`HtmlCssSupport`](#htmlcsssupport)
* [`HtmlPrettyPrint`](#htmlprettyprint)
* [`CssReset`](#cssreset)

## `Html`

An embedded domain specific language (EDSL) in Swift for modeling HTML documents. A few simple value types and functions allow you to model most of HTML, and they compose easily.

```swift
import Html

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

render(document, config: pretty)
```
```html
<html>
  <body>
    <p>Hello world!</p>
    <p>Goodbye!</p>
    <a href="/">Home</a>
  </body>
</html>
```

The design of this library has been covered by the following articles:

* [Type-safe HTML in Swift](http://www.fewbutripe.com/swift/html/dsl/2017/06/22/type-safe-html-in-swift.html)
* [Rendering an HTML DSL in Swift](http://www.fewbutripe.com/swift/html/dsl/2017/06/23/rendering-html-dsl-in-swift.html)
* [Composable HTML Views in Swift](http://www.fewbutripe.com/swift/html/dsl/2017/06/29/composable-html-views-in-swift.html)


## `Css`

An EDSL for a CSS preprocessor like [Sass](http://sass-lang.com). A few simple value types and functions allow you to model most of CSS, and allow you express new things not possible in standard CSS.

```swift
import Css

let css = body % (
  padding(all: .rem(2))
    <> background(Color.hsl(60, 0.5, 0.8))
)

render(css: css)
```
```css
body {
  padding-top    : 2rem;
  padding-right  : 2rem;
  padding-bottom : 2rem;
  padding-left   : 2rem;
  background     : #e6e6b3;
}
```

## `HttpPipeline`

A few types and functions for modeling server middleware as a simple function that transforms a request to a response. It uses phantom types express the state transitions of when you are allowed to write the status, headers and response body.

```swift
import HttpPipeline

let middleware = writeStatus(.ok)
  >>> writeHeader(.contentType(.html))
  >>> closeHeaders
  >>> send(render(document).data(using: .utf8))
  >>> end

let request = URLRequest(url: URL(string: "/")!)
let conn = connection(from: request).map(const(Data?.none))
```
```text
▿ Step
  ResponseEnded

▿ Request
  GET /

  (Data, 0 bytes)

▿ Response
  Status 200 OK
  Content-Type: text/html; charset=utf8

  <html><body><p>Hello world!</p><p>Goodbye!</p><a href="/">Home</a></body></html>
```

## `ApplicativeRouter`

A router built on the principles of “applicative parsing” that is robust, composable and type-safe. Its job is to take the incoming, unstructured `URLRequest` from the browser and turn it into a structured value so that your app can do what it needs to do to produce a response.

```swift
import ApplicativeRouter

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
let route = router.match(requestToRoute) // => Route.episode("001-hello-world")
```

##  `HttpPipelineHtmlSupport`

Adds middleware for rendering an `Html` view:

```swift
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport

let view = View(p(["Hello world!"]))

let middleware = writeStatus(.ok)
  >>> respond(view)

let conn = connection(from: URLRequest(url: URL(string: "/")!))
middleware(conn).response.description
```
```text
Status 200
Content-Type: text/html

<p>Hello world!</p>
```

## `HtmlCssSupport`

Adds an element and attribute function to `Html` for render `Css` values into an internal stylesheet or inline styles. The element function `style` allows you to provide a `Stylesheet` value that will be rendered to an internal stylesheet:

```swift
import Css
import Html
import HtmlCssSupport

let css = body % background(red)
let document = html([head([style(css)])])
render(document)
```
```html
<html>
  <head>
    <style>body{background:#ff0000}</style>
  </head>
</html>
```

The attribute function `style` allows you to render a stylesheet inline directly on an element:

```swift
import Css
import Html
import HtmlCssSupport

let anchorStyle = color(.red)
  <> textTransform(.capitalize)

let styledDocument = p(
  [
    "Go back ",
    a([style(anchorStyle)], ["Home"])
  ]
)
print(render(styledDocument, config: pretty))
```
```html
<p>
  Go back
  <a style="color:#ff0000;text-transform:capitalize">
    Home
  </a>
</p>
```

## `HtmlPrettyPrint`

Contains functions for pretty printing an `Html` node (or nodes) using [DoctorPretty](https://github.com/bkase/DoctorPretty.git), a wonderful little pretty printer library. The implementation of this library has been covered in [this](http://www.fewbutripe.com/swift/html/dsl/2017/07/17/pretty-printing-html.html) article.

The library not only takes care of adding newlines for tags so that the DOM structure is easy to read, but will also insert newlines when text goes past a column width, and even align smartly:

```swift
import HtmlPrettyPrint

let doc: Node = .document(
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

prettyPrint(node: doc, pageWidth: 40)
```
```html
<!DOCTYPE html>
<html>
  <body>
    <!-- This is gonna be a long
         comment. Let's see what
         happens! -->
    <div>
      <div id="some-long-id"
           class="foo bar baz">
        hello world
      </div>
      <img src="cat.jpg"
           alt=""
           id="cat"
           class="cat">
    </div>
  </body>
</html>
```

## `CssReset`

Contains a single value `reset` of type `Stylesheet` that resets all of the defaults for a webpage. It can be combined with another stylesheet via `reset <> otherStyles`, or can be directly rendered to a stylesheet string via `render(reset)`.

## License

All modules are released under the MIT license. See [LICENSE](LICENSE) for details.
