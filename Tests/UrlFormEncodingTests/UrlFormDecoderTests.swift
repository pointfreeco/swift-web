import Prelude
import SnapshotTesting
import UrlFormEncoding
import XCTest

final class UrlFormDecoderTests: XCTestCase {
  let decoder = UrlFormDecoder()

  func testDefaultStrategyAccumulatePairs() throws {
    struct Foo: Decodable {
      let x: Int
      let ys: [Int]
    }

    assertSnapshot(matching: try decoder.decode(Foo.self, from: Data("x=1&ys=1".utf8)))
    assertSnapshot(matching: try decoder.decode(Foo.self, from: Data("x=1&ys=1&ys=2".utf8)))
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

      private enum CodingKeys: String, CodingKey {
        case helloWorld = "hello world"
        case port
        case bar
        case bars
      }
    }

    let data = Data(
      """
      hello%20world=a%20greeting%20for%20you&port=8080&bars[][baz]=1&bars[][baz]=2&bar=&k&
      """.utf8
    )

    decoder.parsingStrategy = .brackets
    assertSnapshot(matching: try decoder.decode(Foo.self, from: data))
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
    assertSnapshot(matching: try decoder.decode(Foo.self, from: data))
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
    assertSnapshot(matching: try decoder.decode(MyDate.self, from: Data("date=1513049223".utf8)))
  }

  func testDateDecodingWithMillisecondsSince1970() throws {
    struct MyDate: Decodable {
      let date: Date
    }

    decoder.dateDecodingStrategy = .millisecondsSince1970
    assertSnapshot(matching: try decoder.decode(MyDate.self, from: Data("date=1513049223123".utf8)))
  }

  func testDateDecodingWithIso8601() throws {
    struct MyDate: Decodable {
      let date: Date
    }

    decoder.dateDecodingStrategy = .iso8601
    assertSnapshot(
      matching: try decoder.decode(MyDate.self, from: Data("date=2017-12-11T20:36:00.000-05:00".utf8))
    )
    assertSnapshot(
      matching: try decoder.decode(MyDate.self, from: Data("date=2017-12-11T20:36:00-05:00".utf8))
    )
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
