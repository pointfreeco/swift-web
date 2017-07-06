# swift-web [![CircleCI](https://circleci.com/gh/pointfreeco/swift-web.svg?style=svg)](https://circleci.com/gh/pointfreeco/swift-web)

A collection of frameworks for solving various problems in a Swift server-side framework. Each framework focuses on a single problem, like HTML rendering, CSS preprocessor, routing, middleware, and more. They also do not depend on any other framework in the collection. You can choose which pieces you want and don’t want, for example you can use `HTML` without `CSS`.

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

* [`HTML`](#HTML)
* [`CSS`](#CSS)
* [`HTTPPipeline`](#HTTPPipeline)
* [`ApplicativeRouter`](#ApplicativeRouter)

## `HTML`

An embedded domain specific language (EDSL) in Swift for modeling HTML documents. A few simple value types and functions allow you to model most of HTML, and they compose easily.

Create nodes by invoking the function with the name of the node and providing an array of nodes for the children:

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

## `HTTPPipeline`

## `ApplicativeRouter`

A router built on the principles of “applicative parsing” that is robust, composable and type-safe. It’s job is to take the incoming, unstructured `URLRequest` from the browser and turn it into a structured value so that your app can do what it needs to do to produce a response.

```swift
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
