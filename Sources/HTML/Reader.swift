import Prelude

public struct Reader<R, A> {
  public let runReader: (R) -> A

  public init(_ f: @escaping (R) -> A) {
    self.runReader = f
  }

  public func map<B>(_ f: @escaping (A) -> B) -> Reader<R, B> {
    return .init(self.runReader >>> f)
  }

  public func contramap<S>(_ f: @escaping (S) -> R) -> Reader<S, A> {
    return .init(f >>> self.runReader)
  }

  public func flatMap<B>(_ f: @escaping (A) -> Reader<R, B>) -> Reader<R, B> {
    return .init { r in f(self.runReader(r)).runReader(r) }
  }

  public func ap<B>(_ f: Reader<R, (A) -> B>) -> Reader<R, B> {
    return Reader<R, B> { r in
      f.runReader(r)(self.runReader(r))
    }
  }

  public static func ask<C>() -> Reader<C, C> { return Reader<C, C>(Prelude.id) }
}

public func pure<R, A>(_ a: A) -> Reader<R, A> {
  return Reader(const(a))
}

public func <¢> <R, A, B> (f: @escaping (A) -> B, x: Reader<R, A>) -> Reader<R, B> {
  return x.map(f)
}

public func >>- <R, A, B> (f: @escaping (A) -> Reader<R, B>, x: Reader<R, A>) -> Reader<R, B> {
  return x.flatMap(f)
}

public func <*> <R, A, B> (f: Reader<R, (A) -> B>, x: Reader<R, A>) -> Reader<R, B> {
  return x.ap(f)
}
