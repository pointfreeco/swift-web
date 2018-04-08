import Foundation
import Html
import HttpPipeline
import Prelude

let doc = document([
  html([
    body([
      p(["Hello world!"]),
      p(["Goodbye!"]),
      a([href("/")], ["Home"])
      ])
    ])
  ])

let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  writeStatus(.ok)
    >-> respond(html: render(doc))

run(middleware, on: 4567)
