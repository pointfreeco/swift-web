import Html
import HttpPipeline
import Prelude

public func respond<Data>(_ view: View<Data>) -> Middleware<HeadersOpen, ResponseEnded, Data, String> {
  return { conn in
    conn.map(view.rendered(with:))
      |> writeHeader(.contentType(.html))
      |> closeHeaders()
      |> end
  }
}
