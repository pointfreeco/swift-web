import Foundation
import Optics
import Prelude

public final class UrlFormDecoder: Decoder {
  private(set) var containers: [Container] = []
  private var container: Container {
    return containers.last!
  }
  public private(set) var codingPath: [CodingKey] = []
  public var dataDecodingStrategy: DataDecodingStrategy = .deferredToData
  public var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate
  public var parsingStrategy: ParsingStrategy = .accumulateValues
  public let userInfo: [CodingUserInfoKey: Any] = [:]

  public init() {
  }

  public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    let query = String(decoding: data, as: UTF8.self)
    let container: Container
    switch self.parsingStrategy {
    case .accumulateValues:
      container = accumulateValues(query)
    case let .custom(strategy):
      container = strategy(query)
    }
    self.containers.append(container)
    defer { self.containers.removeLast() }
    return try T(from: self)
  }

  private func unbox(_ container: Container) -> String? {
    switch self.parsingStrategy {
    case .accumulateValues:
      return container.values?.last?.value
    case .custom:
      return container.value
    }
  }

  private func unbox(_ value: Container, as type: Data.Type) throws -> Data {
    guard let string = unbox(value) else {
      throw Error.decodingError("Expected string data, got \(value)", self.codingPath)
    }

    switch self.dataDecodingStrategy {
    case .deferredToData:
      return try Data(from: self)
    case .base64:
      guard let data = Data(base64Encoded: string) else {
        throw Error.decodingError("Expected base64-encoded data, got \(string)", self.codingPath)
      }
      return data
    case let .custom(strategy):
      guard let data = strategy(string) else {
        throw Error.decodingError("Failed strategy when decoding data from \(string)", self.codingPath)
      }
      return data
    }
  }

  private func unbox(_ value: Container, as type: Date.Type) throws -> Date {
    guard let string = unbox(value) else {
      throw Error.decodingError("Expected string date, got \(value)", self.codingPath)
    }

    switch self.dateDecodingStrategy {
    case .deferredToDate:
      return try Date(from: self)
    case .secondsSince1970:
      guard let date = Double(string).map(Date.init(timeIntervalSince1970:)) else {
        throw Error.decodingError("Expected seconds, got \(string)", self.codingPath)
      }
      return date
    case .millisecondsSince1970:
      guard let date = Double(string).map({ Date(timeIntervalSince1970: $0 / 1000) }) else {
        throw Error.decodingError("Expected milliseconds, got \(string)", self.codingPath)
      }
      return date
    case .iso8601:
      let someDate = iso8601DateFormatter.date(from: string)
        ?? iso8601DateFormatterWithoutMilliseconds.date(from: string)
      guard let date = someDate else {
        throw Error.decodingError("Expected ISO 8601 date string, got \(string)", self.codingPath)
      }
      return date
    case let .formatted(formatter):
      guard let date = formatter.date(from: string) else {
        throw Error.decodingError("Expected \(String(describing: formatter.dateFormat)), got \(string)", self.codingPath)
      }
      return date
    case let .custom(strategy):
      guard let data = strategy(string) else {
        throw Error.decodingError("Failed strategy when decoding data from \(string)", self.codingPath)
      }
      return data
    }
  }

  private func unbox<T: Decodable>(_ value: Container, as type: T.Type) throws -> T {
    if type == Data.self {
      return try self.unbox(value, as: Data.self) as! T
    } else if type == Date.self {
      return try self.unbox(value, as: Date.self) as! T
    } else {
      return try T(from: self)
    }
  }

  public func container<Key>(keyedBy type: Key.Type) throws
    -> KeyedDecodingContainer<Key>
    where Key: CodingKey {

      guard case let .keyed(container) = self.container else {
        throw Error.decodingError("Expected keyed container, got \(self.container)", self.codingPath)
      }
      return .init(KeyedContainer(decoder: self, container: container))
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    guard case let .unkeyed(container) = self.container else {
      throw Error.decodingError("Expected unkeyed container, got \(self.container)", self.codingPath)
    }
    return UnkeyedContainer(decoder: self, container: container, codingPath: self.codingPath)
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    return SingleValueContainer(decoder: self, container: self.container)
  }

  public enum Error: Swift.Error {
    case decodingError(String, [CodingKey])
  }

  struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    private(set) var decoder: UrlFormDecoder
    let container: [String: Container]

    var codingPath: [CodingKey] {
      return self.decoder.codingPath
    }
    var allKeys: [Key] {
      return self.container.keys.compactMap(Key.init(stringValue:))
    }

    private func checked<T>(_ key: Key, _ block: (String) throws -> T) throws -> T {
      guard let value = self.container[key.stringValue].flatMap(self.decoder.unbox) else {
        throw Error.decodingError("Expected \(T.self) at \(key), got nil", self.codingPath)
      }
      return try block(value)
    }

    private func unwrap<T>(_ key: Key, _ block: (String) -> T?) throws -> T {
      guard let value = try self.checked(key, block) else {
        throw Error.decodingError("Expected \(T.self) at \(key), got nil", self.codingPath)
      }
      return value
    }

    func contains(_ key: Key) -> Bool {
      return self.container[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
      return self.container[key.stringValue].flatMap(self.decoder.unbox).map(^\.isEmpty) ?? true
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      return try self.unwrap(key, isTrue)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      return try self.unwrap(key, Int.init)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
      return try self.unwrap(key, Int8.init)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
      return try self.unwrap(key, Int16.init)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
      return try self.unwrap(key, Int32.init)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
      return try self.unwrap(key, Int64.init)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      return try self.unwrap(key, UInt.init)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
      return try self.unwrap(key, UInt8.init)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
      return try self.unwrap(key, UInt16.init)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
      return try self.unwrap(key, UInt32.init)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
      return try self.unwrap(key, UInt64.init)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      return try self.unwrap(key, Float.init)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      return try self.unwrap(key, Double.init)
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
      return try self.unwrap(key, id)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
      self.decoder.codingPath.append(key)
      defer { self.decoder.codingPath.removeLast() }
      guard let container = self.container[key.stringValue] else {
        throw Error.decodingError("Expected \(T.self) at \(key), got nil", self.codingPath)
      }
      self.decoder.containers.append(container)
      defer { self.decoder.containers.removeLast() }
      return try self.decoder.unbox(container, as: T.self)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws
      -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        guard case let .keyed(container)? = self.container[key.stringValue] else {
          throw Error.decodingError("Expected value at \(key), got nil", self.codingPath)
        }
        self.decoder.containers.append(.keyed(container)) // FIXME?
        defer { self.decoder.containers.removeLast() }
        return .init(KeyedContainer<NestedKey>(decoder: self.decoder, container: container))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
      self.decoder.codingPath.append(key)
      defer { self.decoder.codingPath.removeLast() }
      guard case let .unkeyed(container)? = self.container[key.stringValue] else {
        throw Error.decodingError("Expected value at \(key), got nil", self.codingPath)
      }
      self.decoder.containers.append(.unkeyed(container)) // FIXME?
      defer { self.decoder.containers.removeLast() }
      return UnkeyedContainer(decoder: self.decoder, container: container, codingPath: self.codingPath)
    }

    func superDecoder() throws -> Decoder {
      fatalError()
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
      self.decoder.codingPath.append(key)
      defer { self.decoder.codingPath.removeLast() }
      guard let container = self.container[key.stringValue] else {
        throw Error.decodingError("Expected value at \(key), got nil", self.codingPath)
      }
      let decoder = UrlFormDecoder()
      decoder.containers = [container]
      decoder.codingPath = self.codingPath
      decoder.dataDecodingStrategy = self.decoder.dataDecodingStrategy
      decoder.dateDecodingStrategy = self.decoder.dateDecodingStrategy
      decoder.parsingStrategy = self.decoder.parsingStrategy
      return decoder
    }
  }

  struct UnkeyedContainer: UnkeyedDecodingContainer {
    struct Key {
      let index: Int
    }

    let decoder: UrlFormDecoder
    let container: [Container]

    private(set) var codingPath: [CodingKey]
    var count: Int? {
      return self.container.count
    }
    var isAtEnd: Bool {
      return self.currentIndex >= self.container.count
    }
    private(set) var currentIndex: Int = 0

    init(decoder: UrlFormDecoder, container: [Container], codingPath: [CodingKey]) {
      self.decoder = decoder
      self.container = container
      self.codingPath = codingPath
    }

    mutating private func checked<T>(_ block: (String) throws -> T) throws -> T {
      guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
      self.codingPath.append(Key(index: self.currentIndex))
      defer { self.codingPath.removeLast() }
      guard let container = self.decoder.unbox(self.container[self.currentIndex]) else {
        throw Error.decodingError("Expected \(T.self) at \(self.currentIndex), got nil", self.codingPath)
      }
      let value = try block(container)
      self.currentIndex += 1
      return value
    }

    mutating private func unwrap<T>(_ block: (String) -> T?) throws -> T {
      guard let value = try self.checked(block) else {
        throw Error.decodingError("Expected \(T.self) at \(self.currentIndex), got nil", self.codingPath)
      }
      return value
    }

    mutating func decodeNil() throws -> Bool {
      return try self.unwrap(^\.isEmpty)
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
      return try self.unwrap(isTrue)
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
      return try self.unwrap(Int.init)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
      return try self.unwrap(Int8.init)
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
      return try self.unwrap(Int16.init)
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
      return try self.unwrap(Int32.init)
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
      return try self.unwrap(Int64.init)
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
      return try self.unwrap(UInt.init)
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
      return try self.unwrap(UInt8.init)
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
      return try self.unwrap(UInt16.init)
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
      return try self.unwrap(UInt32.init)
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
      return try self.unwrap(UInt64.init)
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
      return try self.unwrap(Float.init)
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
      return try self.unwrap(Double.init)
    }

    mutating func decode(_ type: String.Type) throws -> String {
      return try self.unwrap(id)
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
      guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
      self.codingPath.append(Key(index: self.currentIndex))
      defer { self.codingPath.removeLast() }
      let container = self.container[self.currentIndex]
      self.currentIndex += 1
      self.decoder.containers.append(container)
      defer { self.decoder.containers.removeLast() }
      return try self.decoder.unbox(container, as: T.self)
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws
      -> KeyedDecodingContainer<NestedKey>
      where NestedKey: CodingKey {

        guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
        self.codingPath.append(Key(index: self.currentIndex))
        defer { self.codingPath.removeLast() }
        guard case let .keyed(container) = self.container[self.currentIndex] else {
          throw Error.decodingError("Expected value at \(self.currentIndex), got nil", self.codingPath)
        }
        self.currentIndex += 1
        self.decoder.containers.append(.keyed(container)) // FIXME?
        defer { self.decoder.containers.removeLast() }
        return .init(KeyedContainer(decoder: self.decoder, container: container))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
      guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
      self.codingPath.append(Key(index: self.currentIndex))
      defer { self.codingPath.removeLast() }
      guard case let .unkeyed(container) = self.container[self.currentIndex] else {
        throw Error.decodingError("Expected value at \(self.currentIndex), got nil", self.codingPath)
      }
      self.currentIndex += 1
      self.decoder.containers.append(.unkeyed(container)) // FIXME?
      defer { self.decoder.containers.removeLast() }
      return UnkeyedContainer(decoder: self.decoder, container: container, codingPath: self.codingPath)
    }

    mutating func superDecoder() throws -> Decoder {
      guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
      self.codingPath.append(Key(index: self.currentIndex))
      defer { self.codingPath.removeLast() }
      let container = self.container[self.currentIndex]
      self.currentIndex += 1
      let decoder = UrlFormDecoder()
      decoder.containers = [container]
      decoder.codingPath = self.codingPath
      decoder.dataDecodingStrategy = self.decoder.dataDecodingStrategy
      decoder.dateDecodingStrategy = self.decoder.dateDecodingStrategy
      decoder.parsingStrategy = self.decoder.parsingStrategy
      return decoder
    }
  }

  struct SingleValueContainer: SingleValueDecodingContainer {
    let decoder: UrlFormDecoder
    let container: Container

    let codingPath: [CodingKey] = []

    private func unwrap<T>(_ block: (String) -> T?, _ line: UInt = #line) throws -> T {
      guard
        case let .singleValue(container) = self.container,
        let value = block(container)
        else { throw Error.decodingError("Expected \(T.self), got nil", self.codingPath) }

      return value
    }

    func decodeNil() -> Bool {
      switch self.container {
      case let .singleValue(string):
        return string.isEmpty
      default:
        return false
      }
    }

    func decode(_ type: Bool.Type) throws -> Bool {
      return try self.unwrap(isTrue)
    }

    func decode(_ type: Int.Type) throws -> Int {
      return try self.unwrap(Int.init)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
      return try self.unwrap(Int8.init)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
      return try self.unwrap(Int16.init)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
      return try self.unwrap(Int32.init)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
      return try self.unwrap(Int64.init)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
      return try self.unwrap(UInt.init)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
      return try self.unwrap(UInt8.init)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
      return try self.unwrap(UInt16.init)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
      return try self.unwrap(UInt32.init)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
      return try self.unwrap(UInt64.init)
    }

    func decode(_ type: Float.Type) throws -> Float {
      return try self.unwrap(Float.init)
    }

    func decode(_ type: Double.Type) throws -> Double {
      return try self.unwrap(Double.init)
    }

    func decode(_ type: String.Type) throws -> String {
      return try self.unwrap(id)
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
      self.decoder.containers.append(self.container)
      defer { self.decoder.containers.removeLast() }
      return try self.decoder.unbox(self.container, as: T.self)
    }
  }

  public enum DataDecodingStrategy {
    case deferredToData
    case base64
    case custom((String) -> Data?)
  }

  public enum DateDecodingStrategy {
    case deferredToDate
    case secondsSince1970
    case millisecondsSince1970
    case iso8601
    case formatted(DateFormatter)
    case custom((String) -> Date?)
  }

  public enum Container {
    indirect case keyed([String: Container])
    indirect case unkeyed([Container])
    case singleValue(String)

    var params: [String: Container]? {
      switch self {
      case let .keyed(params):
        return params
      case .unkeyed, .singleValue:
        return nil
      }
    }

    var values: [Container]? {
      switch self {
      case let .unkeyed(values):
        return values
      case .keyed, .singleValue:
        return nil
      }
    }

    var value: String? {
      switch self {
      case let .singleValue(value):
        return value
      case .keyed, .unkeyed:
        return nil
      }
    }
  }

  public enum ParsingStrategy {
    /// A parsing strategy that accumulates values when multiple keys are provided.
    ///
    ///     ids=1&ids=2
    ///     // Parsed as ["ids": ["1", "2"]]
    ///
    /// Wherever the decoder expects a single value (rather than an array), it will use the _last_ value
    /// given.
    ///
    /// - Note: This parsing strategy is "flat" and cannot decode deeper structures.
    case accumulateValues

    /// A parsing strategy that uses a custom function to produce a container for decoding.
    ///
    /// The custom function takes a query string and produces a container for decoding.
    case custom((String) -> Container)

    /// A parsing strategy that uses keys with a bracketed suffix to produce nested structures.
    ///
    /// Keyed, nested structures name each key in brackets.
    ///
    ///     user[name]=Blob&user[email]=blob@pointfree.co
    ///     // Parsed as ["user": ["name": "Blob", "email": "blob@pointfree.co"]]
    ///
    /// Unkeyed, nested structures leave the brackets empty and accumulate single values.
    ///
    ///     ids[]=1&ids[]=2
    ///     // Parsed as ["ids": ["1", "2"]]
    ///
    /// Series of brackets can create deeply-nested structures.
    ///
    ///     user[pets][][id]=1&user[pets][][id]=2
    ///     // Parsed as ["user": ["pets": [["id": "1"], ["id": "2"]]]]
    ///
    /// - Note: Unkeyed brackets do not specify collection indices, so they cannot accumulate complex
    ///   structures by using multiple keys. See `bracketsWithIndices` as an alternative parsing strategy.
    public static let brackets = custom(parse(isArray: ^\.isEmpty))

    /// A parsing strategy that uses keys with a bracketed suffix to produce nested structures.
    ///
    /// Keyed, nested structures name each key in brackets.
    ///
    ///     user[name]=Blob&user[email]=blob@pointfree.co
    ///     // Parsed as ["user": ["name": "Blob", "email": "blob@pointfree.co"]]
    ///
    /// Unkeyed, nested structures name each collection index in brackets and accumulate values.
    ///
    ///     ids[1]=2&ids[0]=1
    ///     // Parsed as ["ids": ["1", "2"]]
    ///
    /// Series of brackets can create deeply-nested structures that accumulate over multiple keys.
    ///
    ///     user[pets][0][id]=1&user[pets][0][name]=Fido
    ///     // Parsed as ["user": ["pets": [["id": "1"], ["name": "Fido"]]]]
    public static let bracketsWithIndices = custom(parse(isArray: { Int($0) != nil }, sort: true))
  }
}

extension UrlFormDecoder.UnkeyedContainer.Key: CodingKey {
  public var stringValue: String {
    return String(self.index)
  }

  public init?(stringValue: String) {
    guard let intValue = Int(stringValue) else { return nil }
    self.init(intValue: intValue)
  }

  public var intValue: Int? {
    return .some(self.index)
  }

  public init?(intValue: Int) {
    self.init(index: intValue)
  }
}

private let iso8601 = ((\DateFormatter.calendar) .~ Calendar(identifier: .iso8601))
  >>> ((\DateFormatter.locale) .~ Locale(identifier: "en_US_POSIX"))
  >>> ((\DateFormatter.timeZone) .~ TimeZone(abbreviation: "GMT"))

private let iso8601DateFormatter = DateFormatter()
  |> iso8601
  |> \.dateFormat .~ "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

private let iso8601DateFormatterWithoutMilliseconds = DateFormatter()
  |> iso8601
  |> \.dateFormat .~ "yyyy-MM-dd'T'HH:mm:ssXXXXX"

private func parse(isArray: @escaping (String) -> Bool, sort: Bool = false) -> (String)
  -> UrlFormDecoder.Container {

    func parseHelp(_ container: inout UrlFormDecoder.Container, _ path: [String], _ value: String) {
      switch container {
      case var .keyed(params):
        let key = path[0]
        if path.count == 1 {
          params[key] = .singleValue(value)
        } else if path.count == 2, isArray(path[1]) {
          var values = params[key]?.values ?? []
          values.append(.singleValue(value))
          params[key] = .unkeyed(values)
        } else if isArray(path[1]) {
          var values = UrlFormDecoder.Container.unkeyed(params[key]?.values ?? [])
          parseHelp(&values, Array(path[1...]), value)
          params[key] = values
        } else {
          var values = UrlFormDecoder.Container.keyed(params[key]?.params ?? [:])
          parseHelp(&values, Array(path[1...]), value)
          params[key] = values
        }
        container = .keyed(params)
      case var .unkeyed(values):
        if path.count == 1 {
          values.append(.singleValue(value))
        } else if isArray(path[1]) {
          var nestedValues = UrlFormDecoder.Container.unkeyed([])
          parseHelp(&nestedValues, Array(path[1...]), value)
          values.append(nestedValues)
        } else {
          var params = UrlFormDecoder.Container.keyed([:])
          parseHelp(&params, Array(path[1...]), value)
          values.append(params)
        }
        container = .unkeyed(values)
      case .singleValue:
        fatalError()
      }
    }

    return { query in
      var params = UrlFormDecoder.Container.keyed([:])

      for (name, value) in pairs(query, sort: sort) {
        let result = name.reduce(into: (path: [] as [String], current: "")) { result, char in
          switch char {
          case "[":
            if result.path.isEmpty {
              result.path.append(result.current)
              result.current.removeAll()
            }
          case "]":
            result.path.append(result.current)
            result.current.removeAll()
          default:
            result.current.append(char)
          }
        }
        let path = result.current.isEmpty ? result.path : result.path + [result.current]
        parseHelp(&params, path.isEmpty ? [""] : path, value ?? "")
      }

      return params
    }
}

public func parse(query: String) -> [(String, String?)] {
  return pairs(query)
}

private func pairs(_ query: String, sort: Bool = false) -> [(String, String?)] {
  let pairs = query
    .split(separator: "&")
    .map { (pairString: Substring) -> (name: String, value: String?) in
      let pairArray = pairString.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
        .compactMap(
          String.init
            >>> { $0.replacingOccurrences(of: "+", with: " ") }
            >>> ^\.removingPercentEncoding
      )
      return (pairArray[0], pairArray.count == 2 ? pairArray[1] : nil)
    }

  return sort ? pairs.sorted { $0.name < $1.name } : pairs
}

private func accumulateValues(_ query: String) -> UrlFormDecoder.Container {
  var params: [String: UrlFormDecoder.Container] = [:]
  for (name, value) in pairs(query) {
    var values = params[name]?.values ?? []
    values.append(.singleValue(value ?? ""))
    params[name] = .unkeyed(values)
  }
  return .keyed(params)
}

private let truths: Set<String> = ["1", "true"]

private func isTrue(_ string: String) -> Bool {
  return truths.contains(string.lowercased())
}
