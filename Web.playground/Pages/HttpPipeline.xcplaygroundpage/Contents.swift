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

let middleware =
  writeStatus(.ok)
    >-> writeHeader(.contentType(.html))
    >-> closeHeaders
    >-> send(Data(render(doc).utf8))

let request = URLRequest(url: URL(string: "/")!)
let conn = connection(from: request).map(const(Data()))

print(middleware(conn).perform())
