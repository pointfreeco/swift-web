import Foundation
import Html
import HttpPipeline
import Prelude

let doc: Node = .document(
  .html(
    .body(
      .p("Hello world!"),
      .p("Goodbye!"),
      .a(attributes: [.href("/")], "Home")
    )
  )
)

let middleware =
  writeStatus(.ok)
    >=> writeHeader(.contentType(.html))
    >=> closeHeaders
    >=> send(Data(render(doc).utf8))

let request = URLRequest(url: URL(string: "/")!)
let conn = connection(from: request).map(const(Data()))

print(middleware(conn).perform())
