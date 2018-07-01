import Css
import Prelude
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import XCTest

class ViewTests: XCTestCase {
  func testSemigroupAssociativity() {
    let a = View<()>(span(["a"]))
    let b = View<()>(span(["b"]))
    let c = View<()>(span(["c"]))

    XCTAssertEqual(
      ((a <> b) <> c).rendered(with: ()),
      (a <> (b <> c)).rendered(with: ())
    )
  }

  func testSemigroup() {
    let greeting = View<Int> {
      [p([text("Welcome to Point Free! We have \($0) episodes for you to watch!")])]
    }
    let header = View<()>(h1(["Point Free"]))
    let footer = View<()>(p(["© Point Free LLC, 2017"]))

    let main = header
      .contramap { _ in () }
      .map { nodes in
        [
          Html.header(
            [ style <| color(.red) ],
            nodes
          )
        ]
      }
      <>
      greeting
      <>
      footer
        .contramap { _ in () }
        .map { nodes in
          [
            Html.footer(
              [ style <| color(.blue) ],
              nodes
            )
          ]
    }

    XCTAssertEqual(
      """
<header style="color:#ff0000;">
  <h1>
    Point Free
  </h1>
</header>
<p>
  Welcome to Point Free! We have 12 episodes for you to watch!
</p>
<footer style="color:#0000ff;">
  <p>
    © Point Free LLC, 2017
  </p>
</footer>
""",
      prettyPrint(nodes: main.view(12))
    )
  }

  func testProfunctor() {
    // Renders some css into a span, and styles the span with that css.
    let styledSpan = View { (css: Stylesheet) in
      span(
        [ style <| css ],
        [ .text(encode(render(config: .compact, css: css))) ]
      )
    }

    // Overrides the color rule of any css by appending it to the end.
    func set(color c: Color) -> (Stylesheet) -> Stylesheet {
      return <>color(c)
    }

    let blueSpan = styledSpan.contramap(set(color: .blue))

    XCTAssertEqual(
      """
<span style="color:#0000ff;">
  {color:#0000ff}
</span>
""",
      prettyPrint(nodes: blueSpan.view(.empty))
    )
  }
}
