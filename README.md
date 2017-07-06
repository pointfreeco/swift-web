# swift-web [![CircleCI](https://circleci.com/gh/pointfreeco/swift-web.svg?style=svg)](https://circleci.com/gh/pointfreeco/swift-web)

A collection of frameworks for solving various problems in building a Swift web framework. Each framework focuses on a single problem, like HTML rendering, CSS preprocessing, routing, middleware, and more. They also do not depend on any other framework in the collection. You can choose which pieces you want and don’t want, for example you can use `HTML` without `CSS`.

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

* [`HTML`](#html)
* [`CSS`](#css)
* [`HTTPPipeline`](#httppipeline)
* [`ApplicativeRouter`](#applicativerouter)

## `HTML`

An embedded domain specific language (EDSL) in Swift for modeling HTML documents. A few simple value types and functions allow you to model most of HTML, and they compose easily.

```swift
import HTML

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


## `CSS`

An EDSL for a CSS preprocessor like [Sass](http://sass-lang.com). A few simple value types and functions allow you to model most of CSS, and allow you express new things not possible in standard CSS.

```swift
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

## `HTTPPipeline`

A few types and functions for modeling server middleware as a simple function that transforms a request to a response.

```swift
let pipeline = writeStatus(.ok)
  >>> writeHeader(.contentType(.text))
  >>> closeHeaders()
  >>> end

let request = URLRequest(url: URL(string: "/")!)
let conn = connection(from: request).map(const("Hello, world"))

pipeline(conn).response.description
```
```text
Status 200
Content-Type: text/plain

Hello, world
```

## `ApplicativeRouter`

A router built on the principles of “applicative parsing” that is robust, composable and type-safe. It’s job is to take the incoming, unstructured `URLRequest` from the browser and turn it into a structured value so that your app can do what it needs to do to produce a response.

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
    <|> Route.episodes <¢ (lit("episodes")) <* end
        // Matches: search?query=
    <|> Route.search <¢> (lit("search") *> opt(param("query"))) <* end

let request = URLRequest(url: URL(string: "http://localhost:8000/episode/001-hello-world")!)
let route = router.match(request) // => Route.episode("001-hello-world")
```

## License

All modules are released under the MIT license. See [LICENSE](LICENSE) for details.
