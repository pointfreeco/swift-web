public struct Status: RawRepresentable {
  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static let `continue` = Status(rawValue: 100)
  public static let switchingProtocols = Status(rawValue: 101)
  public static let processing = Status(rawValue: 102)
  public static let earlyHints = Status(rawValue: 103)
  public static let ok = Status(rawValue: 200)
  public static let created = Status(rawValue: 201)
  public static let accepted = Status(rawValue: 202)
  public static let nonAuthoritiveInformation = Status(rawValue: 203)
  public static let noContent = Status(rawValue: 204)
  public static let resetContent = Status(rawValue: 205)
  public static let partialContent = Status(rawValue: 206)
  public static let multiStatus = Status(rawValue: 207)
  public static let alreadyReported = Status(rawValue: 208)
  public static let imUsed = Status(rawValue: 226)
  public static let multipleChoices = Status(rawValue: 300)
  public static let movedPermanently = Status(rawValue: 301)
  public static let found = Status(rawValue: 302)
  public static let seeOther = Status(rawValue: 303)
  public static let notModified = Status(rawValue: 304)
  public static let useProxy = Status(rawValue: 305)
  public static let switchProxy = Status(rawValue: 306)
  public static let temporaryRedirect = Status(rawValue: 307)
  public static let permanentRedirect = Status(rawValue: 308)
  public static let badRequest = Status(rawValue: 400)
  public static let unauthorized = Status(rawValue: 401)
  public static let paymentRequired = Status(rawValue: 402)
  public static let forbidden = Status(rawValue: 403)
  public static let notFound = Status(rawValue: 404)
  public static let methodNotAllowed = Status(rawValue: 405)
  public static let notAcceptable = Status(rawValue: 406)
  public static let proxyAuthenticationRequired = Status(rawValue: 407)
  public static let requestTimeout = Status(rawValue: 408)
  public static let conflict = Status(rawValue: 409)
  public static let gone = Status(rawValue: 410)
  public static let lengthRequired = Status(rawValue: 411)
  public static let preconditionFailed = Status(rawValue: 412)
  public static let payloadTooLarge = Status(rawValue: 413)
  public static let uriTooLong = Status(rawValue: 414)
  public static let unsupportedMediaType = Status(rawValue: 415)
  public static let rangeNotSatisfiable = Status(rawValue: 416)
  public static let expectationFailed = Status(rawValue: 417)
  public static let imATeapot = Status(rawValue: 418)
  public static let misdirectedRequest = Status(rawValue: 421)
  public static let unprocessableEntity = Status(rawValue: 422)
  public static let locked = Status(rawValue: 423)
  public static let failedDependency = Status(rawValue: 424)
  public static let upgradeRequired = Status(rawValue: 426)
  public static let preconditionRequired = Status(rawValue: 428)
  public static let tooManyRequests = Status(rawValue: 429)
  public static let requestHeaderFieldsTooLarge = Status(rawValue: 431)
  public static let unavailableForLegalReasons = Status(rawValue: 451)
  public static let internalServerError = Status(rawValue: 500)
  public static let notImplemented = Status(rawValue: 501)
  public static let badGateway = Status(rawValue: 502)
  public static let serviceUnavailable = Status(rawValue: 503)
  public static let gatewayTimeout = Status(rawValue: 504)
  public static let httpVersionNotSupported = Status(rawValue: 505)
  public static let variantAlsoNegotiates = Status(rawValue: 506)
  public static let insufficientStorage = Status(rawValue: 507)
  public static let loopDetected = Status(rawValue: 508)
  public static let notExtended = Status(rawValue: 510)
  public static let networkAuthenticationRequired = Status(rawValue: 511)
}

extension Status: CustomStringConvertible {
  public var description: String {
    switch self.rawValue {
    case 100: return "Continue"
    case 101: return "Switching Protocols"
    case 102: return "Processing"
    case 103: return "Early Hints"
    case 200: return "OK"
    case 201: return "Created"
    case 202: return "Accepted"
    case 203: return "Non-Authoritative Information"
    case 204: return "No Content"
    case 205: return "Reset Content"
    case 206: return "Partial Content"
    case 207: return "Multi-Status"
    case 208: return "Already Reported"
    case 226: return "IM Used"
    case 300: return "Multiple Choices"
    case 301: return "Moved Permanently"
    case 302: return "Found"
    case 303: return "See Other"
    case 304: return "Not Modified"
    case 305: return "Use Proxy"
    case 306: return "Switch Proxy"
    case 307: return "Temporary Redirect"
    case 308: return "Permanent Redirect"
    case 400: return "Bad Request"
    case 401: return "Unauthorized"
    case 402: return "Payment Required"
    case 403: return "Forbidden"
    case 404: return "Not Found"
    case 405: return "Method Not Allowed"
    case 406: return "Not Acceptable"
    case 407: return "Proxy Authentication Required"
    case 408: return "Request Timeout"
    case 409: return "Conflict"
    case 410: return "Gone"
    case 411: return "Length Required"
    case 412: return "Precondition Failed"
    case 413: return "Payload Too Large"
    case 414: return "URI Too Long"
    case 415: return "Unsupported Media Type"
    case 416: return "Range Not Satisfiable"
    case 417: return "Expectation Failed"
    case 418: return "I'm a teapot"
    case 421: return "Misdirected Request"
    case 422: return "Unprocessable Entity"
    case 423: return "Locked"
    case 424: return "Failed Dependency"
    case 426: return "Upgrade Required"
    case 428: return "Precondition Required"
    case 429: return "Too Many Requests"
    case 431: return "Request Header Fields Too Large"
    case 451: return "Unavailable For Legal Reasons"
    case 500: return "Internal Server Error"
    case 501: return "Not Implemented"
    case 502: return "Bad Gateway"
    case 503: return "Service Unavailable"
    case 504: return "Gateway Timeout"
    case 505: return "HTTP Version Not Supported"
    case 506: return "Variant Also Negotiates"
    case 507: return "Insufficient Storage"
    case 508: return "Loop Detected"
    case 510: return "Not Extended"
    case 511: return "Network Authentication Required"
    default: return String(describing: self.rawValue)
    }
  }
}
