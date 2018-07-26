import Prelude

public enum Node {
  case comment(String)
  case doctype(String)
  indirect case element(String, [(key: String, value: String)], [Node])
  case raw(String)
  case text(String)
}

extension Node: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .text(value)
  }
}
