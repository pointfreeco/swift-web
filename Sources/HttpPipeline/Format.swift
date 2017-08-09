public enum Format {
  case json
  case html
  case text
  case other(String)

  var description: String {
    switch self {
    case .json:
      return "application/json"
    case .html:
      return "text/html"
    case .text:
      return "text/plain"
    case let .other(str):
      return str
    }
  }
}
