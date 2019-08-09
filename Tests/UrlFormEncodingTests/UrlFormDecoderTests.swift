import Prelude
import SnapshotTesting
import UrlFormEncoding
import XCTest

final class UrlFormDecoderTests: XCTestCase {
  let decoder = UrlFormDecoder()

  override func setUp() {
    super.setUp()
//    record = true
  }

  func testOptionality() throws {
    struct Foo: Decodable {
      let x: Int?
    }

    XCTAssertNil(try decoder.decode(Foo.self, from: Data()).x)
    XCTAssertNil(try decoder.decode(Foo.self, from: Data("foo=bar".utf8)).x)
    XCTAssertEqual(1, try decoder.decode(Foo.self, from: Data("x=1".utf8)).x)
  }

  func testPlusses() throws {
    struct Foo: Decodable {
      let x: String
    }

    XCTAssertEqual("hello world", try decoder.decode(Foo.self, from: Data("x=hello+world".utf8)).x)
  }

  func testDefaultStrategyAccumulatePairs() throws {
    struct Foo: Decodable {
      let x: Int
      let ys: [Int]
    }

    assertSnapshot(matching: try decoder.decode(Foo.self, from: Data("x=1&ys=1".utf8)), as: .dump)
    assertSnapshot(matching: try decoder.decode(Foo.self, from: Data("x=1&ys=1&ys=2".utf8)), as: .dump)

    // FIXME: Make work!
//    XCTAssertNil(try decoder.decode(Foo?.self, from: Data("ys=1&ys=2".utf8)))
//    XCTAssertNil(try decoder.decode(Foo?.self, from: Data()))
  }

  func testBrackets() throws {
    struct Bar: Decodable {
      let baz: Int
    }

    struct Foo: Decodable {
      let helloWorld: String
      let port: Int
      let bar: Bar?
      let bars: [Bar]
      let barses: [[Bar]]

      private enum CodingKeys: String, CodingKey {
        case helloWorld = "hello world"
        case port
        case bar
        case bars
        case barses
      }
    }

    let data = Data(
      """
      hello%20world=a%20greeting%20for%20you&\
      port=8080&\
      bars[][baz]=1&\
      bars[][baz]=2&\
      bar=&\
      barses[][][baz]=3&\
      barses[][][baz]=4&\
      k&&
      """.utf8
    )

    decoder.parsingStrategy = .brackets

    assertSnapshot(matching: try decoder.decode(Foo.self, from: data), as: .dump)
  }

  func testBracketsWithIndices() throws {
    struct Bar: Decodable {
      let baz: Int
    }

    struct Foo: Decodable {
      let helloWorld: String
      let port: Int
      let bar: Bar?
      let bars: [Bar]

      private enum CodingKeys: String, CodingKey {
        case helloWorld = "hello world"
        case port
        case bar
        case bars
      }
    }

    let data = Data(
      """
      hello%20world=a%20greeting%20for%20you&port=8080&bars[1][baz]=2&bars[0][baz]=1&bar=&k&
      """.utf8
    )

    decoder.parsingStrategy = .bracketsWithIndices

    assertSnapshot(matching: try decoder.decode(Foo.self, from: data), as: .dump)
  }

  func testDataDecodingWithBase64() throws {
    struct MyData: Decodable {
      let data: Data
    }

    decoder.dataDecodingStrategy = .base64

    XCTAssertEqual(
      "OOPs",
      String(decoding: try decoder.decode(MyData.self, from: Data("data=T09Qcw==".utf8)).data, as: UTF8.self)
    )
  }

  func testDateDecodingWithSecondsSince1970() throws {
    struct MyDate: Decodable {
      let date: Date
    }

    decoder.dateDecodingStrategy = .secondsSince1970
    let interval = Int(Date(timeIntervalSinceReferenceDate: 0).timeIntervalSince1970)

    assertSnapshot(matching: try decoder.decode(MyDate.self, from: Data("date=\(interval)".utf8)), as: .dump)
  }

  func testDateDecodingWithMillisecondsSince1970() throws {
    struct MyDate: Decodable {
      let date: Date
    }

    decoder.dateDecodingStrategy = .millisecondsSince1970
    let interval = "\(Int(Date(timeIntervalSinceReferenceDate: 0).timeIntervalSince1970))000"

    assertSnapshot(matching: try decoder.decode(MyDate.self, from: Data("date=\(interval)".utf8)), as: .dump)
  }

  func testDateDecodingWithIso8601() throws {
    struct MyDate: Decodable {
      let date: Date
    }
    decoder.dateDecodingStrategy = .iso8601

    assertSnapshot(
      matching: try decoder.decode(MyDate.self, from: Data("date=2001-01-01T00:00:00.000-00:00".utf8)),
      as: .dump
    )
    assertSnapshot(
      matching: try decoder.decode(MyDate.self, from: Data("date=2001-01-01T00:00:00-00:00".utf8)),
      as: .dump
    )
  }

  func testBools() {
    struct MyBool: Decodable {
      let bool: Bool
    }
    XCTAssertTrue(try decoder.decode(MyBool.self, from: Data("bool=true".utf8)).bool)
    XCTAssertTrue(try decoder.decode(MyBool.self, from: Data("bool=TRUE".utf8)).bool)
    XCTAssertTrue(try decoder.decode(MyBool.self, from: Data("bool=1".utf8)).bool)
    XCTAssertFalse(try decoder.decode(MyBool.self, from: Data("bool=false".utf8)).bool)
    XCTAssertFalse(try decoder.decode(MyBool.self, from: Data("bool=FALSE".utf8)).bool)
    XCTAssertFalse(try decoder.decode(MyBool.self, from: Data("bool=0".utf8)).bool)
  }

//  func testDateDecodingWithFormatted() throws {
//    struct MyDate: Decodable {
//      let date: Date
//    }
//
//    let formatter = DateFormatter()
//    formatter.locale = Locale(identifier: "en_US")
//    formatter.setLocalizedDateFormatFromTemplate("MMMMdyyyy")
//
//    decoder.dateDecodingStrategy = .formatted(formatter)
//    assertSnapshot(matching: try decoder.decode(MyDate.self, from: Data("date=December%2031,%202017".utf8)))
//  }
}
