import Css
import DoctorPretty
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import SnapshotTesting
import XCTest

class PrettyTests: XCTestCase {
  override func setUp() {
    super.setUp()
    record = true
  }

  func testPretty() {

    let doc: [Node] = [
      .doctype("html"),
      html(
        [
          body(
            [
              .comment("This is gonna be a long comment. Let's see what happens!"),
              div(
                [
                  div(
                    [
                      id("some-long-id"),
                      Html.class("foo bar baz class1 class2 class3"),
                      style("color: red;background: blue;padding: rem(2);")
                    ],
                    ["hello world"]
                  ),
                  p([
                    """
Tacit programming, also called point-free style, is a programming paradigm in which function definitions do \
not identify the arguments (or "points") on which they operate.
"""
                    ]),
                  img([src("cat.jpg"), alt(""), id("cat"), Html.class("cat")])
                ]
              )
            ]
          )
        ]
      )
    ]

    assertSnapshot(matching: prettyPrint(doc), pathExtension: "html")
  }

  func testDocument() {
    let doc = html(
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
                  [.init("xmlns", "http://www.w3.org/2000/svg"), width(100), height(100)],
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
                            ),
                            p(
                              [
                                """
Side effects: can’t live with ’em; can’t write a program without ’em. Let’s explore a few kinds of side \
effects we encounter every day, why they make code difficult to reason about and test, and how we can \
control them without losing composition.
"""
                              ]
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
                            ),
                            p(
                              [
                                """
Our first episode is all about functions! We talk a bit about what makes functions special, contrasting \
them with the way we usually write code, and have some exploratory discussions about operators and \
composition.
"""
                              ]
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

            hr([Html.class("pf-divider border-top m-ml0 m-mr0 m-mt0 m-mb0 bg-white")]),

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

    assertSnapshot(matching: prettyPrint(doc), pathExtension: "html")
  }
}
