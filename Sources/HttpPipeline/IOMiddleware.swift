import Optics
import Prelude

public func >-> <I, J, K, A, B, C>(
  lhs: @escaping Middleware<I, J, A, IO<B>>,
  rhs: @escaping Middleware<J, K, B, IO<C>>
  )
  ->
  Middleware<I, K, A, IO<C>> {

    return lhs >>> map(perform) >>> rhs
}

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

public func resolve<I, A>(_ conn: Conn<I, IO<A>>) -> Conn<I, A> {
  return Conn(
    data: conn.data.perform(),
    request: conn.request,
    response: conn.response
  )
}

public func resolve<I, A>(_ conn: IO<Conn<I, A>>) -> Conn<I, A> {
  return conn.perform()
}

func flip<I, A>(_ conn: Conn<I, IO<A>>) -> IO<Conn<I, A>> {
  return IO<Conn<I, A>> { conn.map(const(conn.data.perform())) }
}
