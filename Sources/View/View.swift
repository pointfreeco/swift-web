import Html
import Prelude

public typealias View<D> = Func<D, Node>
extension View {
  public func view(_ data: A) -> B {
    return self.call(data)
  }
}
