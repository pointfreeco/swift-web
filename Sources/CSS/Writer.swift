import Prelude

struct Writer<M: Monoid, A> {
  let m: M
  let a: A

  static func pure(_ a: A) -> Writer {
    return .init(m: .empty, a: a)
  }

  func bind<B>(_ f: (A) -> Writer<M, B>) -> Writer<M, B> {
    let newWriter = f(self.a)
    return .init(
      m: self.m <> newWriter.m,
      a: newWriter.a
    )
  }

  func run() -> (M, A) {
    return (self.m, self.a)
  }

  func exec() -> M {
    return self.m
  }
}

extension Writer where A == Unit {
  static func tell(_ m: M) -> Writer<M, Unit> {
    return .init(m: m, a: unit)
  }
}

func >>- <M, A, B> (x: Writer<M, A>, f: (A) -> Writer<M, B>) -> Writer<M, B> {
  return x.bind(f)
}

