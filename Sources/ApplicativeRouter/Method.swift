// TODO: should we move this to its own package so both the router and pipeline can use?
public enum Method: String {
  case get, post, put, patch, delete, options, head
}

extension Method {
  public init?(string: String) {
    self.init(rawValue: string.lowercased())
  }
}
