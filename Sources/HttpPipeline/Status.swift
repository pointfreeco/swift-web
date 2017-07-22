public enum Status: Int {
  case ok = 200
  case created = 201
  case noContent = 204

  case movedPermanently = 301
  case found = 302
  case notModified = 304
  case temporaryRedirect = 307
  case permanentRedirect = 308

  case badRequest = 400
  case unauthorized = 401
  case forbidden = 403
  case notFound = 404
  case methodNotAllowed = 405
  case notAcceptable = 406
  case tooManyRequests = 429

  //  case custom(Int/* , String */) // TODO
}
