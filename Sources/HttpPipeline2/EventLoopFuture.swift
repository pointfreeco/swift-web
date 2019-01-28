import NIO
import Prelude

public func >=> <A, B, C>(f: @escaping (A) -> EventLoopFuture<B>, g: @escaping (B) -> EventLoopFuture<C>)
  -> (A) -> EventLoopFuture<C> {

    return { f($0).flatMap(g) }
}
