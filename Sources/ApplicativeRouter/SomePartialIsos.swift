import Foundation
import Optics
import Prelude

public let stringToInt = PartialIso<String, Int>(
  image: Int.init,
  preimage: String.init
)

public let stringToNum = PartialIso<String, Double>(
  image: Double.init,
  preimage: String.init
)

public let anyToString = PartialIso<Any, String>(
  image: { "\($0)" },
  preimage: id
)

public let stringToBool = PartialIso<String, Bool>(
  image: { $0 == "true" || $0 == "1" },
  preimage: { $0 ? "true" : "false" }
)

public let stringToFormData = PartialIso<String, [String: String]>(
  image: bodyStringToFormData,
  preimage: formDataToBodyString
)

public let stringToData = PartialIso<String, Data>(
  image: { Data($0.utf8) },
  preimage: { String(data: $0, encoding: .utf8) }
)

extension PartialIso where A: Codable, B == Data {
  public static var codableToDictionary: PartialIso<A, Data> {
    return .init(
      image: {
        (try? JSONEncoder().encode($0))
          .flatMap { try? JSONSerialization.data(withJSONObject: $0) }

    },
      preimage: {
        (try? JSONSerialization.data(withJSONObject: $0))
          .flatMap { try? JSONDecoder().decode(A.self, from: $0) }
    })
  }
}

private func bodyStringToFormData(_ body: String) -> [String: String] {
  let pairs = body.split(separator: "&")
    .map {
      $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
        .flatMap(String.init >>> Prelude.get(\.removingPercentEncoding))
    }
    .map { ($0[0], $0[1]) }
  return [String: String](uniqueKeysWithValues: pairs)
}

private func formDataToBodyString(_ data: [String: String]) -> String {
  let t = URLComponents()
    |> \.queryItems .~ data.map(URLQueryItem.init(name:value:))
  return t.query ?? ""
}
