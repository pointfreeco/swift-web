import Css
import Html
import HtmlCssSupport
import HtmlTestSupport
import Prelude
import SnapshotTesting
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
                background(Color.rgb(240, 240, 240))
              )
            ),
            script("alert(\"hello world!\")")
          ]
        ),
        body(
          [ Html.class("home"), id("home") ],
          [
            header(
              [ Html.class("site-header") ],
              [
                svg(
                  [xmlns("http://www.w3.org/2000/svg"), width(100), height(100)],
                  """
<circle cx="50" cy="50" r="40" stroke="green" stroke-width="4" fill="yellow" />
"""
                ),
                a([ href("/home") ], [ "Home" ]),
                nav(
                  [ Html.class("site-nav") ],
                  [
                    div(
                      [
                        a([href("/episodes")], ["Episodes"]),
                        a([href("/About")], ["About"]),
                      ]
                    )
                  ]
                )
              ]
            ),

            main(
              [ Html.class("page-content") ],
              [
                h1(
                  [ Html.class("page-heading") ],
                  [
                    ul(
                      [ Html.class("episode-list") ],
                      [
                        li(
                          [
                            span(
                              [ Html.class("episode-metadata") ],
                              [ "April 27, 2017" ]
                            ),
                            h2(
                              [ a([href("/episode/2")], ["Episode #2"]) ]
                            )
                          ]
                        ),
                        li(
                          [
                            span(
                              [ Html.class("episode-metadata") ],
                              [ "April 20, 2017" ]
                            ),
                            h2(
                              [ a([href("/episode/1")], ["Episode #1"]) ]
                            )
                          ]
                        ),
                      ]
                    )
                  ]
                ),
                p(
                  [ Html.class("rss-subscribe") ],
                  [
                    "subscribe ",
                    a(
                      [ href("/rss.xml") ],
                      [ "via RSS" ]
                    )
                  ]
                )
              ]
            ),

            footer(
              [ Html.class("site-footer") ],
              [
                h2(["The Site"]),
                ul(
                  [
                    li([a([href("#")], ["Contact us"])]),
                    li([a([href("#")], ["About"])]),
                    li([a([href("#")], ["Home"])]),
                  ]
                ),
                form(
                  [ id("newsletter-form"), action("#"), Html.method(.post) ],
                  [
                    h4(["Sign up for our newsletter!"]),
                    label([Html.for("email")], ["Email: "]),
                    input([type(.text), Html.name("email"), id("email"), Html.value("")]),
                    input([type(.submit), Html.value("Submit")])
                  ]
                )
              ]
            ),
            script("/* google analytics */")
          ]
        )
      ]
    )

    assertSnapshot(matching: htmlNode)
  }
}
