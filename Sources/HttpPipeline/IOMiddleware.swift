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


//func resolve<I, A>(_ future: Future<Conn<I, A>>) -> Conn<I, A> {
//
//  var conn: Conn<I, A>!
//
//  let sema = DispatchSemaphore(value: 0)
//  future.onResult { result in
//    sema.signal()
//    conn = result
//  }
//  sema.wait()
//
//  return conn
//}
//
//func resolve<I, A>(_ future: Conn<I, Future<A>>) -> Conn<I, A> {
//  fatalError()
//}
//
//
