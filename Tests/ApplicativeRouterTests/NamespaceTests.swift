import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest
import SnapshotTesting
import HttpPipelineTestSupport

enum MainRoute: Equatable {
  case page(Page)

  enum Page {
    case index
    case show(Int)
  }

  static func == (lhs: MainRoute, rhs: MainRoute) -> Bool {
    switch (lhs, rhs) {
    case (.page(.index), .page(.index)):
      return true
    case let (.page(.show(lhs)), .page(.show(rhs))):
      return lhs == rhs
    default:
      return false
    }
  }
}

extension PartialIso where A == MainRoute.Page, B == MainRoute {
  static var page: PartialIso {
    return parenthesize <| PartialIso(
      apply: MainRoute.page,
      unapply: {
        guard case let .page(result) = $0 else { return nil }
        return result
    })
  }
}

extension PartialIso where A == Prelude.Unit, B == MainRoute.Page {
  static var index: PartialIso {
    return parenthesize <| PartialIso.init(
      apply: const(.some(.index)),
      unapply: {
        guard case .index = $0 else { return nil }
        return .some(Prelude.unit)
    })
  }
}

extension PartialIso where A == Int, B == MainRoute.Page {
  static var show: PartialIso {
    return parenthesize <| PartialIso.init(
      apply: MainRoute.Page.show,
      unapply: {
        guard case let .show(result) = $0 else { return nil }
        return result
    })
  }
}

private let flatRouter: Router<MainRoute> =
  .page <<< .index
    <¢> get %> lit("page") %> lit("index") %> end

    <|> .page <<< .show
    <¢> get %> lit("page") %> lit("show") %> .int <% end


private let namespacedRouter: Router<MainRoute> =
  lit("page")
    %> (
      .page <<< .index
        <¢> get %> lit("index") %> end

        <|> .page <<< .show
        <¢> get %> lit("show") %> .int <% end
)

class NamespaceTests: XCTestCase {
  func testNamespace() {

    XCTAssertEqual(
      .page(.index),
      flatRouter.match(string: "/page/index")
    )
    XCTAssertEqual(
      .page(.show(2)),
      flatRouter.match(string: "/page/show/2")
    )
    XCTAssertEqual(
      "/page/index",
      flatRouter.absoluteString(for: .page(.index))
    )
    XCTAssertEqual(
      "/page/show/2",
      flatRouter.absoluteString(for: .page(.show(2)))
    )


    XCTAssertEqual(
      .page(.index),
      namespacedRouter.match(string: "/page/index")
    )
    XCTAssertEqual(
      .page(.show(2)),
      namespacedRouter.match(string: "/page/show/2")
    )
    XCTAssertEqual(
      "/page/index",
      namespacedRouter.absoluteString(for: .page(.index))
    )
    XCTAssertEqual(
      "/page/show/2",
      namespacedRouter.absoluteString(for: .page(.show(2)))
    )
  }
}
