import Html
import HtmlPrettyPrint

let doc = document([
  html([
    body([
      p(["Hello world!"]),
      p(["Goodbye!"]),
      a([href("/")], ["Home"])
      ])
    ])
  ])

print(prettyPrint(node: doc))
