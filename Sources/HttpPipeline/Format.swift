public enum Format {
  case json
  case html
  case text

  case custom(String)

  var description: String {
    switch self {
    case .json:
      return "application/json"
    case .html:
      return "text/html"
    case .text:
      return "text/plain"
    case let .custom(str):
      return str
    }
  }
}
