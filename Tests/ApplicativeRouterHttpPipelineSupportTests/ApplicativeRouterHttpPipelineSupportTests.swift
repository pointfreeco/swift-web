import ApplicativeRouter
import ApplicativeRouterHttpPipelineSupport
import HttpPipeline
import HttpPipelineTestSupport
import Prelude
import SnapshotTesting
import XCTest

class ApplicativeRouterHttpPipelineSupportTests: XCTestCase {
  func testRoute() {
    let router =
      Route.iso.home <¢> get <% end
        <|> Route.iso.episode <¢> get %> lit("episode") %> .string <% end

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Never, Never, Prelude.Unit, Data> =
      route(router: router)
        <| writeStatus(.ok)

        >>> map(map { Data("Recognized route: \($0)".utf8) })
        // FIXME: for snapshot to render body
        >-> writeHeader(.contentType(.plain))
        >-> { $0 |> writeHeader(.contentLength($0.data.right!.count)) }

        >-> closeHeaders
        >-> end

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "/")!))).perform(),
      named: "home"
    )

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "/episode/ep1-hello-world")!))).perform(),
      named: "episode"
    )

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "/does/not/exist")!))).perform(),
      named: "unrecognized"
    )
  }

  func testRoute_UnrecognizedWithCustomNotFound() {
    let router = Route.iso.home <¢> get <% end

    let middleware: Middleware<StatusLineOpen, ResponseEnded, Never, Never, Prelude.Unit, Data> =
      route(router: router, notFound: notFound(respond(text: "Unrecognized route!")))
        <| writeStatus(.ok)

        >>> map(map { Data("Recognized route: \($0)".utf8) })
        // FIXME: for snapshot to render body
        >-> writeHeader(.contentType(.plain))
        >-> { $0 |> writeHeader(.contentLength($0.data.right!.count)) }

        >-> closeHeaders
        >-> end

    assertSnapshot(
      matching: middleware(connection(from: URLRequest(url: URL(string: "/does/not/exist")!))).perform(),
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
