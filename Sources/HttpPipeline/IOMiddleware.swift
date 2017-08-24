import Prelude

public func >-> <I, J, K, A, B, C>(
  lhs: @escaping Middleware<I, J, A, IO<B>>,
  rhs: @escaping Middleware<J, K, B, IO<C>>
  )
  ->
  Middleware<I, K, A, IO<C>> {

    return lhs >>> map(perform) >>> rhs
}

public func resolve<I, A>(_ conn: Conn<I, IO<A>>) -> Conn<I, A> {
  return Conn(
    data: conn.data.perform(),
    request: conn.request,
    response: conn.response
  )
}
