import Prelude

public func >-> <I, J, K, A, B, C>(
  _ lhs: @escaping (Conn<I, A>) -> IO<Conn<J, B>>,
  _ rhs: @escaping (Conn<J, B>) -> IO<Conn<K, C>>
  )
  -> (Conn<I, A>)
  -> IO<Conn<K, C>> {

    return { conn in
      return flatMap(rhs) <| lhs(conn)
    }
}

public func resolve<I, A>(_ conn: IO<Conn<I, A>>) -> Conn<I, A> {
  return conn.perform()
}

public func resolve<I, A>(_ conn: Conn<I, IO<A>>) -> Conn<I, A> {
  return Conn(
    data: conn.data.perform(),
    request: conn.request,
    response: conn.response
  )
}
