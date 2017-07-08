import Css
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import Prelude
import XCTest

class FullDocumentTests: XCTestCase {

  func testDocument() {
    let htmlNode = html(
      [],
      [
        head(
          [
            title("The Site Title"),
            style(
              body % (
                background(rgb(240, 240, 240))
              )
            )
          ]
        ),
        body(
          [ Html.class <| "home",
            id <| "home"
          ],
          [
            header(
              [ Html.class <| "site-header" ],
              [
                a([ href <| "/home" ], [ "Home" ]),
                nav(
                  [ Html.class <| "site-nav" ],
                  [
                    div(
                      [
                        a([href <| "/episodes"], ["Episodes"]),
                        a([href <| "/About"], ["About"]),
                      ]
                    )
                  ]
                )
              ]
            ),

            main(
              [ Html.class <| "page-content" ],
              [
                h1(
                  [ Html.class <| "page-heading" ],
                  [
                    ul(
                      [ Html.class <| "episode-list" ],
                      [
                        li(
                          [
                            span(
                              [ Html.class <| "episode-metadata" ],
                              [ "April 27, 2017" ]
                            ),
                            h2(
                              [ a([href <| "/episode/2"], ["Episode #2"]) ]
                            )
                          ]
                        ),
                        li(
                          [
                            span(
                              [ Html.class <| "episode-metadata" ],
                              [ "April 20, 2017" ]
                            ),
                            h2(
                              [ a([href <| "/episode/1"], ["Episode #1"]) ]
                            )
                          ]
                        ),
                      ]
                    )
                  ]
                ),
                p(
                  [ Html.class <| "rss-subscribe" ],
                  [
                    "subscribe ",
                    a(
                      [ href <| "/rss.xml" ],
                      [ "via RSS" ]
                    )
                  ]
                )
              ]
            ),

            footer(
              [ Html.class <| "site-footer" ],
              [
                h2(["The Site"]),
                ul(
                  [
                    a([href <| "#"], ["Contact us"]),
                    a([href <| "#"], ["About"]),
                    a([href <| "#"], ["Home"]),
                  ]
                ),
                form(
                  [ id <| "newsletter-form", action <| "#", Html.method <| .post ],
                  [
                    h4(["Sign up for our newsletter!"]),
                    label([Html.for <| "email"], ["Email: "]),
                    input([type <| "text", Html.name <| "email", id <| "email", Html.value <| ""]),
                    input([type <| "submit", Html.value <| "Submit"])
                  ]
                )
              ]
            )
          ]
        )
      ]
    )

    XCTAssertEqual(
      """
<html>
  <head>
    <title>
      The Site Title
    </title>
    <style>
      body{background:#f0f0f0}
    </style>
  </head>
  <body class="home" id="home">
    <header class="site-header">
      <a href="/home">
        Home
      </a>
      <nav class="site-nav">
        <div>
          <a href="/episodes">
            Episodes
          </a>
          <a href="/About">
            About
          </a>
        </div>
      </nav>
    </header>
    <main class="page-content">
      <h1 class="page-heading">
        <ul class="episode-list">
          <li>
            <span class="episode-metadata">
              April 27, 2017
            </span>
            <h2>
              <a href="/episode/2">
                Episode #2
              </a>
            </h2>
          </li>
          <li>
            <span class="episode-metadata">
              April 20, 2017
            </span>
            <h2>
              <a href="/episode/1">
                Episode #1
              </a>
            </h2>
          </li>
        </ul>
      </h1>
      <p class="rss-subscribe">
        subscribe\u{20}
        <a href="/rss.xml">
          via RSS
        </a>
      </p>
    </main>
    <footer class="site-footer">
      <h2>
        The Site
      </h2>
      <ul>
        <a href="#">
          Contact us
        </a>
        <a href="#">
          About
        </a>
        <a href="#">
          Home
        </a>
      </ul>
      <form id="newsletter-form" action="#" method="POST">
        <h4>
          Sign up for our newsletter!
        </h4>
        <label for="email">
          Email:\u{20}
        </label>
        <input type="text" name="email" id="email" value="" />
        <input type="submit" value="Submit" />
      </form>
    </footer>
  </body>
</html>
""",
      prettyPrint(node: htmlNode)
    )
  }
}
