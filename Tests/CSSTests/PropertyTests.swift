import XCTest
import Prelude
import CSS

class PropertyTests: XCTestCase {
  func testPrefixed_Monoid() {

    let lhs1 = Prefixed.plain("a")
    let rhs1 = Prefixed.plain("b")

    XCTAssertEqual(.plain("ab"), lhs1 <> rhs1)

    let lhs2 = Prefixed.plain("a")
    let rhs2 = Prefixed.prefixed([("b", "c"), ("d", "e")])

    XCTAssertEqual(.prefixed([("b", "ac"), ("d", "ae")]), lhs2 <> rhs2)

    let lhs3 = Prefixed.prefixed([("b", "c"), ("d", "e")])
    let rhs3 = Prefixed.plain("a")

    XCTAssertEqual(.prefixed([("b", "ca"), ("d", "ea")]), lhs3 <> rhs3)

    let lhs4 = Prefixed.prefixed([("a",   "b"), ("c", "d")])
    let rhs4 = Prefixed.prefixed([("c", "e")])

    XCTAssertEqual(.prefixed([("c", "de")]), lhs4 <> rhs4)

    let lhs5 = Prefixed.prefixed([("a",   "b"), ("c", "d")])
    let rhs5 = Prefixed.prefixed([("c", "e")])

    XCTAssertEqual(.prefixed([("c", "de")]), lhs5 <> rhs5)
  }

  static var allTests = [
    ("testPrefixed_Monoid", testPrefixed_Monoid),
    ]
}

