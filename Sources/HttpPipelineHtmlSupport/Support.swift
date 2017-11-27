import Foundation
import Html
import HttpPipeline
import Prelude

public func respond<E, A>(_ view: View<A>) -> Middleware<HeadersOpen, ResponseEnded, E, E, A, Data> {
  
  return
    map { Data(view.rendered(with: $0).utf8) }
      >>> writeHeader(.contentType(.html))
      >-> closeHeaders
      >-> end
}
