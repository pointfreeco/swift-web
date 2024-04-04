import Foundation
import HTTPTypes

public struct Response {
  public var status: Status
  public var headers: HTTPFields
  public var body: Data
}
