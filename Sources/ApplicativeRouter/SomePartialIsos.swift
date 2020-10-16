import Either
import Foundation
import Optics
import Prelude
import UrlFormEncoding

extension Optional {
  public enum iso {
    /// A partial isomorphism `(A) -> A?` 
    public static var some: PartialIso<Wrapped, Wrapped?> {
      return .init(
        apply: Optional.some,
        unapply: id
      )
    }
  }
}

/// Lifts a partial isomorphism `(A) -> B` to one `(A?) -> B?`, which means that it never fails since it can
/// fallback to mapping to `.some(.none)`.
public func opt<A, B>(_ f: PartialIso<A, B>) -> PartialIso<A?, B?> {
  return PartialIso<A?, B?>(
    apply: { $0.flatMap(f.apply) },
    unapply: { $0.flatMap(f.unapply) }
  )
}

public func opt<A, B>(_ iso: PartialIso<A, B>, default: B) -> PartialIso<A?, B> {
  .init(
    apply: {
      switch $0 {
      case let .some(a):
        return iso.apply(a)
      case .none:
        return `default`
      }
    },
    unapply: {
      iso.unapply($0)
    }
  )
}

/// Lifts a partial isomorphism `(A) -> B` to one `(A?) -> B`.
public func req<A, B>(_ f: PartialIso<A, B>) -> PartialIso<A?, B> {
  return Optional.iso.some.inverted >>> f
}

extension PartialIso where A == String, B == Int {
  /// An isomorphism between strings and integers.
  public static var int: PartialIso {
    return PartialIso(
      apply: Int.init,
      unapply: String.init
    )
  }
}

// TODO: possible to document this in the applicative of Syntax?

extension PartialIso where A == String, B == Bool {
  /// An isomorphism between strings and booleans.
  public static var bool: PartialIso {
    return .init(
      apply: {
        $0 == "true" || $0 == "1" ? true
          : $0 == "false" || $0 == "0" ? false
          : nil
      },
      unapply: { $0 ? "true" : "false" }
    )
  }
}

extension PartialIso where A == String, B == String {
  /// The identity isomorphism between strings.
  public static var string: PartialIso {
    return .id
  }
}

extension PartialIso where A == String, B == Double {
  /// An isomorphism between strings and doubles.
  public static var double: PartialIso {
    return PartialIso(
      apply: Double.init,
      unapply: String.init(_:)
    )
  }
}

extension PartialIso where A == String, B == [(key: String, value: String?)] {
  /// An isomorphism between strings and dictionaries using form encoded format.
  public static var formEncodedFields: PartialIso {
    return .init(
      apply: formEncodedStringToFields,
      unapply: fieldsToFormEncodedString
    )
  }
}

extension PartialIso where A == String, B == Data {
  /// An isomorphism between strings and data using utf8 encoding.
  /// TODO: this should prob take encoding as an argument.
  public static var data: PartialIso {
    return .init(
      apply: ^\.utf8 >>> Data.init(_:),
      unapply: { String(decoding: $0, as: UTF8.self) }
    )
  }
}

extension PartialIso where A: Codable, B == Data {
  public static func codableToJsonData(
    _ type: A.Type,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
    )
    -> PartialIso {

      return .init(
        apply: { try? encoder.encode($0) },
        unapply: { try? decoder.decode(type, from: $0) }
      )
  }

  /// FIXME: build/use UrlFormEncoder
  public static func codableToFormData(_ type: A.Type, decoder: UrlFormDecoder = .init()) -> PartialIso {
    return .init(
      apply: urlFormEncode(value:) >>> ^\.utf8 >>> Data.init(_:),
      unapply: { try? decoder.decode(type, from: $0) }
    )
  }
}

public let jsonDictionaryToData = PartialIso<[String: String], Data>(
  apply: { try? JSONSerialization.data(withJSONObject: $0) },
  unapply: {
    (try? JSONSerialization.jsonObject(with: $0))
      .flatMap { $0 as? [String: String] }
})

public func first<A>(where predicate: @escaping (A) -> Bool) -> PartialIso<[A], A> {
  return PartialIso<[A], A>(
    apply: { $0.first(where: predicate) },
    unapply: { [$0] }
  )
}

public func filter<A>(_ isIncluded: @escaping (A) -> Bool) -> PartialIso<[A], [A]> {
  return PartialIso<[A], [A]>(
    apply: { $0.filter(isIncluded) },
    unapply: id
  )
}

public func key<K, V>(_ key: K) -> PartialIso<[K: V], V> {
  return PartialIso<[K: V], V>(
    apply: { $0[key] },
    unapply: { [key: $0] }
  )
}

public func keys<K, V>(_ keys: [K]) -> PartialIso<[K: V], [K: V]> {
  return .init(
    apply: { $0.filter { key, _ in keys.contains(key) } },
    unapply: id
  )
}

extension PartialIso where A == String, B == Either<String, Int> {
  public static var intOrString: PartialIso<String, Either<String, Int>> {
    return PartialIso<String, Either<String, Int>>(
      apply: { Int($0).map(Either.right) ?? .left($0) },
      unapply: { $0.right.map(String.init) ?? $0.left }
    )
  }
}

private func formEncodedStringToFields(_ body: String) -> [(key: String, value: String?)] {
  return parse(query: body)
}

private func fieldsToFormEncodedString(_ data: [(key: String, value: String?)]) -> String {
  var urlComponents = URLComponents()
  urlComponents.queryItems = data.map(URLQueryItem.init(name:value:))
  return urlComponents.percentEncodedQuery ?? ""
}

extension PartialIso where B: RawRepresentable, B.RawValue == A {
  public static var rawRepresentable: PartialIso {
    return .init(
      apply: B.init(rawValue:),
      unapply: ^\.rawValue
    )
  }
}

extension PartialIso where A == String, B == UUID {
  public static var uuid: PartialIso<String, UUID> {
    return PartialIso(
      apply: UUID.init(uuidString:),
      unapply: ^\.uuidString
    )
  }
}
