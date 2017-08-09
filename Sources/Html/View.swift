import Prelude

public typealias View<D> = FunctionM<D, [Node]>

extension View {
  public func view(_ data: A) -> M {
    return self.call(data)
  }
}

// MARK: Helpers

extension View where M == [Node] {
  public func rendered(with data: A) -> String {
    return self.rendered(with: data, config: compact)
  }

  public func rendered(with data: A, config: Config) -> String {
    return render(self.view(data), config: config)
  }

  public init(_ call: @escaping (A) -> Node) {
    self.call = call >>> pure
  }

  public init(_ node: Node) {
    self.call = const([node])
  }
}

extension View where A == (), M == [Node] {
  public init(_ call: @escaping (A) -> Node) {
    self.call = call >>> pure
  }

  public init(_ node: Node) {
    self.call = const([node])
  }
}
