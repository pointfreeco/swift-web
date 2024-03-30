import Foundation
import Html
import HTTPTypes
import Optics
import Prelude

public struct Response {
  public var status: Status
  public var headers: HTTPFields
  public var body: Data
}
