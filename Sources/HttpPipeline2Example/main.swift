import HttpPipeline2
import Prelude

let app: AppMiddleware =
  writeStatus(.ok)
    >=> respond(html: "<h1>Hello!</h1>")

run(app)
