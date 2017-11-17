import ApplicativeRouter
import Either
import Optics
import Prelude
import XCTest

import Foundation

//func XCTAssertRequestEqual(_ lhs: URLRequest, _ rhs: URLRequest) {
//
//}

class SyntaxRouterTests: XCTestCase {

  // BUG: https://bugs.swift.org/browse/SR-6407

  // The two tests below are identical except one has a `dump` and the other doesnt.

  func testFailsWithoutDump() {
    var lhs = URLRequest(url: URL(string: "http://www.pointfree.co/home")!)
    lhs.httpMethod = "GET"
    let rhs = router.request(for: .root, base: URL(string: "http://www.pointfree.co/"))!
    XCTAssertEqual(lhs, rhs)
  }


  func testPassesWithDump() {
    var lhs = URLRequest(url: URL(string: "http://www.pointfree.co/home")!)
    lhs.httpMethod = "get"
    let rhs = router.request(for: .root, base: URL(string: "http://www.pointfree.co/"))!
    dump(lhs)
    XCTAssertEqual(lhs, rhs)
  }

  // This test is also identical except i have removed the line setting the `httpMethod`

  func testPassesWithoutSettingMethod() {
    let lhs = URLRequest(url: URL(string: "http://www.pointfree.co/home")!)
    let rhs = router.request(for: .root, base: URL(string: "http://www.pointfree.co/"))!
    XCTAssertEqual(lhs, rhs)
  }

}
