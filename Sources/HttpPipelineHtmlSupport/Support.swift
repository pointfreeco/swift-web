import Foundation
import Html
import HttpPipeline
import Prelude

public func respond<A>(_ view: View<A>) -> Middleware<HeadersOpen, ResponseEnded, A, Data?> {
  
  return
    map { view.rendered(with: $0).data(using: .utf8) }
      >>> pure
      >-> writeHeader(.contentType(.html))
      >-> closeHeaders
      >-> end
}
