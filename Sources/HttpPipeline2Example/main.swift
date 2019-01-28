import Foundation
import HttpPipeline2
import NIO
import Prelude

let app: AppMiddleware =
  writeStatus(.ok)
    >=> respond(html: "<h1>Hello!</h1>\n")

run(app)
