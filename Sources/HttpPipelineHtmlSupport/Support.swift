import Foundation
import Html
import HttpPipeline
import Prelude

public func respond<A>(_ view: View<A>) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return respond(body: view.rendered(with: $0), contentType: .html)
}
