import Foundation
import Optics
import Prelude

extension Optional {
  public enum iso {
    public static var some: PartialIso<Wrapped, Wrapped?> {
      return PartialIso<Wrapped, Wrapped?>(
        image: { .some($0) },
        preimage: { $0 }
      )
    }
  }
}

/// Lifts a partial isomorphism `(A) -> B` to one `(A) -> B?`.
public func opt<A, B>(_ f: PartialIso<A, B>) -> PartialIso<A, B?> {
  return f >>> Optional.iso.some
}

extension PartialIso where A == String, B == Int {
  public static var int: PartialIso {
    return .init(
      image: Int.init,
      preimage: String.init
    )
  }
}

// TODO: possible to document this in the applicative of Syntax?
extension PartialIso where A == String, B == Bool {
  public static var bool: PartialIso {
    return .init(
      image: { $0 == "true" || $0 == "1" },
      preimage: { $0 ? "true" : "false" }
    )
  }
}

extension PartialIso where A == String, B == String {
  public static var bool: PartialIso {
    return .id
  }
}

extension PartialIso where A == String, B == Double {
  public static var double: PartialIso {
    return .init(
      image: Double.init,
      preimage: String.init
    )
  }
}

extension PartialIso where A == String , B == String {
  public static var string: PartialIso {
    return .init(
      image: { $0 },
      preimage: { $0 }
    )
  }
}

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

public let jsonDictionaryToData = PartialIso<[String: String], Data>(
  image: { try? JSONSerialization.data(withJSONObject: $0) },
  preimage: {
    (try? JSONSerialization.jsonObject(with: $0))
      .flatMap { $0 as? [String: String] }
})

public func key<K, V>(_ key: K) -> PartialIso<[K: V], V> {
  return PartialIso<[K: V], V>(
    image: { $0[key] },
    preimage: { [key: $0] }
  )
}

public func keys<K, V>(_ keys: [K]) -> PartialIso<[K: V], [K: V]> {
  return .init(
    image: { $0.filter { key, _ in keys.contains(key) } },
    preimage: id
  )
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
