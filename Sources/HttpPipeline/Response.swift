import Foundation

public struct Response {
  public var status: Status
  public private(set) var headers: [ResponseHeader]
  public private(set) var body: Data
}
