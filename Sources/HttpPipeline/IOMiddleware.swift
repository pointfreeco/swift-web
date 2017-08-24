import Prelude

public func >-> <I, J, K, A, B, C>(
  _ lhs: @escaping (Conn<I, A>) -> Conn<J, IO<B>>,
  _ rhs: @escaping (Conn<J, B>) -> Conn<K, IO<C>>
  )
  -> (Conn<I, A>)
  -> Conn<K, IO<C>> {

    return { conn in
      rhs(lhs(conn).map { ioB in ioB.perform() })
    }
}

public func resolve<I, A>(_ conn: Conn<I, IO<A>>) -> Conn<I, A> {
  return Conn(
    data: conn.data.perform(),
    request: conn.request,
    response: conn.response
  )
}
