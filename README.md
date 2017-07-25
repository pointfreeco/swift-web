# swift-web [![CircleCI](https://circleci.com/gh/pointfreeco/swift-web.svg?style=svg)](https://circleci.com/gh/pointfreeco/swift-web)

A collection of frameworks for solving various problems in building a Swift web framework. Each framework focuses on a single problem, like HTML rendering, CSS preprocessing, routing, middleware, and more. They also do not depend on any other framework in the collection. You can choose which pieces you want and don’t want, for example you can use `Html` without `Css`.

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

## Table of Contents

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
        p(["Goodbye!"],
        [ a([href("/")], ["Home"]) ]
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
  padding(all: rem(2))
    <> background(hsl(60, 0.5, 0.8))
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

A few types and functions for modeling server middleware as a simple function that transforms a request to a response.

```swift
let middleware = writeStatus(.ok)
  >>> writeHeader(.contentType(.text))
  >>> closeHeaders()
  >>> end

let request = URLRequest(url: URL(string: "/")!)
let conn = connection(from: request).map(const("Hello, world"))

middleware(conn).response.description
```
```text
Status 200
Content-Type: text/plain

Hello, world
```

## `ApplicativeRouter`

A router built on the principles of “applicative parsing” that is robust, composable and type-safe. Its job is to take the incoming, unstructured `URLRequest` from the browser and turn it into a structured value so that your app can do what it needs to do to produce a response.

```swift
import ApplicativeRouter

enum Route {
  case home
  case episodes
  case episode(String)
  case search(String?)
}

let router =
        // Matches: /
        Route.home <¢ end
        // Matches: /episode/:str
    <|> Route.episode <¢> (lit("episode") *> str) <* end
        // Matches: /episodes
    <|> Route.episodes <¢ lit("episodes") <* end
        // Matches: search?query=
    <|> Route.search <¢> (lit("search") *> opt(param("query"))) <* end

let request = URLRequest(url: URL(string: "http://localhost:8000/episode/001-hello-world")!)
let route = router.match(request) // => Route.episode("001-hello-world")
```

##  `HttpPipelineHtmlSupport`

Adds middleware for rendering an `Html` view:

```swift
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude

let view = View<Prelude.Unit> { _ in p(["Hello world!"]) }

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

let document = p(
  [ style(color(blue)) ],
  [
    "Go back ",
    a([style(color(red))], ["Home"])
  ]
)
render(document)
```
```html
<p style="color:#0000ff">
  Go back
  <a style="color:#ff0000">Home</a>
</p>
```

## `HtmlPrettyPrint`

Contains functions for pretty printing an `Html` node (or nodes) using [DoctorPretty](https://github.com/bkase/DoctorPretty.git), a wonderful little pretty printer library. It not only takes care of adding newlines for tags so that the DOM structure is easy to read, but will also insert newlines when text goes past a column width, and even align smartly:

```swift
let doc: Node = .document(
  [
    body(
      [
        .comment("This is gonna be a long comment. Let's see what happens!"),
        div(
          [
            div([ id("some-long-id"), Html.`class`("foo bar baz"), ], ["hello world"]),
            img([ id("cat"), Html.`class`("cat"), src("cat.jpg") ])
          ]
        )
      ]
    )
  ]
)

prettyPrint(node: doc, pageWidth: 40))
```
```html
<!DOCTYPE html>
<body>
  <!-- This is gonna be a long comment.
       Let's see what happens! -->
  <div>
    <div id="some-long-id"
         class="foo bar baz">
      hello world
    </div>
    <img id="cat"
         class="cat"
         src="cat.jpg" />
  </div>
</body>
```

## `CssReset`

Contains a single value `reset` of type `Stylesheet` that resets all of the defaults for a webpage. It can be combined with another stylesheet via `reset <> otherStyles`, or can be directly rendered to a stylesheet string via `render(reset)`.

## License

All modules are released under the MIT license. See [LICENSE](LICENSE) for details.
