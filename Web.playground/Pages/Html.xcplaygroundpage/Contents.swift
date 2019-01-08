import Html

let doc = document([
  html([
    body([
      p(["Hello world!"]),
      p(["Goodbye!"]),
      a([href("/")], ["Home"])
      ])
    ])
  ])

print(debugRender(doc))
