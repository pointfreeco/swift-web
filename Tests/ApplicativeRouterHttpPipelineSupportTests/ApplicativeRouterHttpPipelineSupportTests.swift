import ApplicativeRouter
import ApplicativeRouterHttpPipelineSupport
import HttpPipeline
import HttpPipelineTestSupport
import Prelude
import SnapshotTesting
import XCTest

class ApplicativeRouterHttpPipelineSupportTests: XCTestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testRoute() {
    let router =
      Route.iso.home <¢> get <% end
        <|> Route.iso.episode <¢> get %> lit("episode") %> .string <% end

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      route(router: router)
        <| writeStatus(.ok)
        >=> { $0 |> respond(text: "Recognized route: \($0.data)") }

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "/")!), defaultHeaders: [])).perform(),
      as: .conn,
      named: "home"
    )

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "/episode/ep1-hello-world")!), defaultHeaders: [])).perform(),
      as: .conn,
      named: "episode"
    )

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "/does/not/exist")!), defaultHeaders: [])).perform(),
      as: .conn,
      named: "unrecognized"
    )
  }

  func testRoute_UnrecognizedWithCustomNotFound() {
    let router = Route.iso.home <¢> get <% end

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
      route(router: router, notFound: notFound(respond(text: "Unrecognized route!")))
        <| writeStatus(.ok)
        >=> { $0 |> respond(text: "Recognized route: \($0.data)") }

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "/does/not/exist")!), defaultHeaders: [])).perform(),
      as: .conn,
      named: "unrecognized"
    )
  }
}

enum Route {
  case home
  case episode(String)

  enum iso {
    static let home = parenthesize <| PartialIso<Prelude.Unit, Route>(
      apply: const(Route.home),
      unapply: {
        if case .home = $0 { return unit }
        return nil
    })

    static let episode = parenthesize <| PartialIso<String, Route>(
      apply: Route.episode,
      unapply: {
        if case let .episode(result) = $0 { return result }
        return nil
    })
  }
}
