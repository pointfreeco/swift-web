public enum Method {
  case get
  case post
  case put
  case patch
  case delete
  case options
  case other(String)

  public var description: String {
    switch self {
    case .get:
      return "GET"
    case .post:
      return "POST"
    case .put:
      return "PUT"
    case .patch:
      return "PATCH"
    case .delete:
      return "DELETE"
    case .options:
      return "OPTIONS"
    case let .other(str):
      return str
    }
  }
}
