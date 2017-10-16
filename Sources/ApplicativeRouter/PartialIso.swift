import Prelude

// todo: use a profunctor Iso?
//typealias Iso_<S, T, A, B> = ((S) -> A) -> ((B) -> T)

// todo: move to prelude?

/// A partial isomorphism is a partial function that is invertible on the parts it is defined, i.e.
/// `image(x) = y` if and only `preimage(y) = x`.
public struct PartialIso<A, B> {
  public let image: (A) -> B?
  public let preimage: (B) -> A?

  public init(image: @escaping (A) -> B?, preimage: @escaping (B) -> A?) {
    self.image = image
    self.preimage = preimage
  }

  /// Inverts the partial isomorphism.
  public var inverted: PartialIso<B, A> {
    return .init(image: self.preimage, preimage: self.image)
  }

  /// A partial isomorphism between `(A, B)` and `(B, A)`.
  public static var commute: PartialIso<(A, B), (B, A)> {
    return .init(
      image: { ($1, $0) },
      preimage: { ($1, $0) }
    )
  }

  /// Composes two partial isomorphisms.
  public static func >>> <C> (lhs: PartialIso<A, B>, rhs: PartialIso<B, C>) -> PartialIso<A, C> {
    return .init(
      image: lhs.image >-> rhs.image,
      preimage: rhs.preimage >-> lhs.preimage
    )
  }
}

extension PartialIso where B == A {
  /// The identity partial isomorphism.
  public static var id: PartialIso {
    return .init(image: { $0 }, preimage: { $0 })
  }
}

extension PartialIso where B == (A, Prelude.Unit) {
  /// An isomorphism between `A` and `(A, Unit)`.
  public static var unit: PartialIso {
    return .init(
      image: { ($0, Prelude.unit) },
      preimage: { $0.0 }
    )
  }
}

/// Converts a partial isomorphism of a flat 1-tuple to one of a right-weighted nested tuple.
public func parenthesize<A, B>(_ f: PartialIso<A, B>) -> PartialIso<A, B> {
  return f
}

/// Converts a partial isomorphism of a flat 2-tuple to one of a right-weighted nested tuple.
public func parenthesize<A, B, C>(_ f: PartialIso<(A, B), C>) -> PartialIso<(A, B), C> {
  return f
}

/// Converts a partial isomorphism of a flat 3-tuple to one of a right-weighted nested tuple.
public func parenthesize<A, B, C, D>(_ f: PartialIso<(A, B, C), D>) -> PartialIso<(A, (B, C)), D> {
  return flatten() >>> f
}

/// Converts a partial isomorphism of a flat 4-tuple to one of a right-weighted nested tuple.
public func parenthesize<A, B, C, D, E>(_ f: PartialIso<(A, B, C ,D), E>) -> PartialIso<(A, (B, (C, D))), E> {
  return flatten() >>> f
}

// TODO: should we just bite the bullet and create our own `TupleN` types and stop using Swift tuples
// altogether?

/// Flattens a right-weighted nested 3-tuple.
private func flatten<A, B, C>() -> PartialIso<(A, (B, C)), (A, B, C)> {
  return .init(
    image: { ($0.0, $0.1.0, $0.1.1) },
    preimage: { ($0, ($1, $2)) }
  )
}

/// Flattens a left-weighted nested 4-tuple.
private func flatten<A, B, C, D>() -> PartialIso<(A, (B, (C, D))), (A, B, C, D)> {
  return .init(
    image: { ($0.0, $0.1.0, $0.1.1.0, $0.1.1.1) },
    preimage: { ($0, ($1, ($2, $3))) }
  )
}

