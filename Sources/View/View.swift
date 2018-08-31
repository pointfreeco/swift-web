import Html
import Prelude

public typealias View<D> = Func<D, [Node]>
extension View {
  public func view(_ data: A) -> B {
    return self.call(data)
  }
}

//// MARK: Helpers
extension View where B == [Node] {
  // todo: move to pointfreeco
//  public func rendered(with data: A, config: Config = .compact) -> String {
//    return render(self.view(data), config: config)
//  }
  public init(_ call: @escaping (A) -> Node) {
    self.init(call >>> pure)
  }
  public init(_ node: Node) {
    self.init(const([node]))
  }
}
