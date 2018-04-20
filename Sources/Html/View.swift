import Prelude

public typealias View<D> = Func<D, [Node]>

extension View {
  public func view(_ data: A) -> B {
    return self.call(data)
  }
}

// MARK: Helpers

extension View where B == [Node] {
  public func rendered(with data: A) -> String {
    return self.rendered(with: data, config: compact)
  }

  public func rendered(with data: A, config: Config) -> String {
    return render(self.view(data), config: config)
  }
}
