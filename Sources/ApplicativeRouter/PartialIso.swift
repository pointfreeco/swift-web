import Prelude

// todo: use a profunctor Iso?
//typealias Iso_<S, T, A, B> = ((S) -> A) -> ((B) -> T)

// todo: move to prelude?
public struct PartialIso<A, B> {
  public let image: (A) -> B?
  public let preimage: (B) -> A?

  public var inverted: PartialIso<B, A> {
    return .init(image: self.preimage, preimage: self.image)
  }

  public static var commute: PartialIso<(A, B), (B, A)> {
    return .init(
      image: { ($1, $0) },
      preimage: { ($1, $0) }
    )
  }

  public static func >>> <C> (lhs: PartialIso<A, B>, rhs: PartialIso<B, C>) -> PartialIso<A, C> {
    return .init(
      image: lhs.image >-> rhs.image,
      preimage: rhs.preimage >-> lhs.preimage
    )
  }

  public static var id: PartialIso<A, A> {
    return .init(image: { $0 }, preimage: { $0 })
  }

  public var optional: PartialIso<A, B?> {
    return self >>> Optional.iso.some
  }
}

public func parenthesize<A, B, C, D>(_ f: PartialIso<(A, B, C), D>) -> PartialIso<(A, (B, C)), D> {
  return flatten() >>> f
}

public func parenthesize<A, B, C, D, E>(_ f: PartialIso<(A, B, C ,D), E>) -> PartialIso<(A, (B, (C, D))), E> {
  return flatten() >>> f
}

public func parenthesize<A, B, C>(_ f: PartialIso<(A, B), C>) -> PartialIso<(A, B), C> {
  return f
}

public func parenthesize<A, B>(_ f: PartialIso<A, B>) -> PartialIso<A, B> {
  return f
}

extension PartialIso where B == (A, Prelude.Unit) {
  public static var unit: PartialIso {
    return .init(
      image: { ($0, Prelude.unit) },
      preimage: { $0.0 }
    )
  }
}

extension Optional {
  public enum iso {
    public static var some: PartialIso<Wrapped, Wrapped?> {
      return PartialIso<Wrapped, Wrapped?>(
        image: { $0 },
        preimage: { $0 }
      )
    }
  }
}

// todo: since we are using the appliciatve `f a -> f b -> f (a, b)` we will often run into
// right-paranthesized nested tuples e.g. (A, (B, (C, D))), so we will need many overloads of `flatten` to
// correct this :/

private func flatten<A, B, C>() -> PartialIso<(A, (B, C)), (A, B, C)> {
  return .init(
    image: { ($0.0, $0.1.0, $0.1.1) },
    preimage: { ($0, ($1, $2)) }
  )
}

private func flatten<A, B, C, D>() -> PartialIso<(A, (B, (C, D))), (A, B, C, D)> {
  return .init(
    image: { ($0.0, $0.1.0, $0.1.1.0, $0.1.1.1) },
    preimage: { ($0, ($1, ($2, $3))) }
  )
}

