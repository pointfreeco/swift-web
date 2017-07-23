import Prelude

public enum Color: Val, Auto, Inherit, None {
  case rgba(UInt8, UInt8, UInt8, Float)
  case other(Value)

  public func value() -> Value {
    switch self {
    case let .rgba(red, green, blue, alpha):
      let formatted = alpha == 1.0
        ? "#" + phex(red) + phex(green) + phex(blue)
        : "rgba(\(red),\(green),\(blue),\(alpha))"
      return .init(.plain(formatted))
    case let .other(value):
      return value
    }
  }

  public static let auto: Color = .other(.auto)
  public static let inherit: Color = .other(.inherit)
  public static let none: Color = .other(.none)

  public static func rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Color {
    return .rgba(red, green, blue, 1.0)
  }

  public static func hsla(_ hue: Int, _ saturation: Float, _ lightness: Float, _ alpha: Float)
    -> Color {
      let (r, g, b) = hsl2rgb(hue, saturation, lightness)
      return .rgba(r, g, b, alpha)
  }

  public static func hsl(_ h: Int, _ s: Float, _ l: Float) -> Color {
    return hsla(h, s, l, 1)
  }

  public static func white(_ white: Float, _ alpha: Float = 1.0) -> Color {
    let w = toUInt8(white)
    return .rgba(w, w, w, alpha)
  }

  public static let red = rgba(255, 0, 0, 1)
  public static let green = rgba(0, 255, 0, 1)
  public static let blue = rgba(0, 0, 255, 1)
}

extension Color: _ExpressibleByColorLiteral {
  public init(colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
    self = .rgba(toUInt8(red), toUInt8(green), toUInt8(blue), alpha)
  }
}

public extension Color {
  public private(set) var red: UInt8? {
    get {
      guard case let .rgba(r, _, _, _) = self else { return nil }
      return r
    }
    set(r) {
      guard let r = r, case let .rgba(_, g, b, a) = self else { return }
      self = .rgba(r, g, b, a)
    }
  }

  public private(set) var green: UInt8? {
    get {
      guard case let .rgba(r, _, _, _) = self else { return nil }
      return r
    }
    set(r) {
      guard let r = r, case let .rgba(_, g, b, a) = self else { return }
      self = .rgba(r, g, b, a)
    }
  }

  public private(set) var blue: UInt8? {
    get {
      guard case let .rgba(r, _, _, _) = self else { return nil }
      return r
    }
    set(r) {
      guard let r = r, case let .rgba(_, g, b, a) = self else { return }
      self = .rgba(r, g, b, a)
    }
  }

  public private(set) var alpha: Float? {
    get {
      guard case let .rgba(_, _, _, a) = self else { return nil }
      return a
    }
    set(a) {
      guard let a = a, case let .rgba(r, g, b, _) = self else { return }
      self = .rgba(r, g, b, a)
    }
  }

  public private(set) var hue: Int? {
    get {
      guard case let .rgba(r, g, b, _) = self else { return nil }
      return rgb2hsl(r, g, b).hue
    }
    set(h) {
      guard let h = h, case let .rgba(r, g, b, a) = self else { return }
      let (_, s, l) = rgb2hsl(r, g, b)
      let (red, green, blue) = hsl2rgb(h, s, l)
      self = .rgba(red, green, blue, a)
    }
  }

  public private(set) var saturation: Float? {
    get {
      guard case let .rgba(r, g, b, _) = self else { return nil }
      return rgb2hsl(r, g, b).saturation
    }
    set(s) {
      guard let s = s, case let .rgba(r, g, b, a) = self else { return }
      let (h, _, l) = rgb2hsl(r, g, b)
      let (red, green, blue) = hsl2rgb(h, s, l)
      self = .rgba(red, green, blue, a)
    }
  }

  public private(set) var lightness: Float? {
    get {
      guard case let .rgba(r, g, b, _) = self else { return nil }
      return rgb2hsl(r, g, b).lightness
    }
    set(l) {
      guard let l = l, case let .rgba(r, g, b, a) = self else { return }
      let (h, s, _) = rgb2hsl(r, g, b)
      let (red, green, blue) = hsl2rgb(h, s, l)
      self = .rgba(red, green, blue, a)
    }
  }
}

public func darken(_ by: Float) -> (Color) -> Color {
  return over(\Color.lightness) <| { $0.map { $0 * (1 - by) } }
}

public func lighten(_ by: Float) -> (Color) -> Color {
  return over(\Color.lightness) <| { $0.map { $0 * (1 + by) } }
}

public func saturate(_ by: Float) -> (Color) -> Color {
  return over(\Color.saturation) <| { $0.map { $0 * (1 + by) } }
}

public func desaturate(_ by: Float) -> (Color) -> Color {
  return over(\Color.saturation) <| { $0.map { $0 * (1 - by) } }
}

//extension Color: Equatable {
//  public static func ==(lhs: Color, rhs: Color) -> Bool {
//    return toUInt8(lhs.red) == toUInt8(rhs.red)
//      && toUInt8(lhs.blue) == toUInt8(rhs.blue)
//      && toUInt8(lhs.green) == toUInt8(rhs.green)
//      && toUInt8(lhs.alpha) == toUInt8(rhs.alpha)
//  }
//}

private func rgb2hsl(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> (hue: Int, saturation: Float, lightness: Float) {
  let (r, g, b) = (toFloat(r), toFloat(g), toFloat(b))

  let maximum = max(r, max(g, b))
  let minimum = min(r, min(g, b))
  let c = maximum - minimum

  let hPrime: Float
  if c == 0 {
    hPrime = 0
  } else if maximum == r {
    hPrime = ((g - b) / c).truncatingRemainder(dividingBy: 6)
  } else if maximum == g {
    hPrime = ((b - r) / c) + 2
  } else if maximum == b {
    hPrime = ((r - g) / c) + 4
  } else {
    fatalError()
  }

  let h = Int(hPrime * 60)
  let l = 0.5 * (maximum + minimum)
  let s = l == 1
    ? 0
    : c / (1 - abs(2 * l - 1))

  return (h, s, l)
}

private func hsl2rgb(_ h: Int, _ s: Float, _ l: Float) -> (red: UInt8, green: UInt8, blue: UInt8) {
  let c = (1 - abs(2 * l - 1)) * s
  let hPrime = Float(h) / 60
  let hPrimePrime = hPrime.truncatingRemainder(dividingBy: 2)
  let x = c * (1 - abs(hPrimePrime - 1))

  let (r1, g1, b1): (Float, Float, Float)
  switch hPrime {
  case (0..<1):
    (r1, g1, b1) = (c, x, 0)
  case (1..<2):
    (r1, g1, b1) = (x, c, 0)
  case (2..<3):
    (r1, g1, b1) = (0, c, x)
  case (3..<4):
    (r1, g1, b1) = (0, x, c)
  case (4..<5):
    (r1, g1, b1) = (x, 0, c)
  case (5..<6):
    (r1, g1, b1) = (c, 0, x)
  default:
    (r1, g1, b1) = (0, 0, 0)
  }

  let m = l - 0.5 * c
  let (r, g, b) = (r1 + m, g1 + m, b1 + m)

  return (toUInt8(r), toUInt8(g), toUInt8(b))
}

private func clamped<T>(_ to: Range<T>) -> (T) -> T {
  return { element in
    min(to.upperBound, max(to.lowerBound, element))
  }
}

private func phex(_ n: UInt8) -> String {
  return (n < 16 ? "0" : "") + String(n, radix: 16, uppercase: false)
}

private func toFloat(_ x: UInt8) -> Float {
  return Float(x) / 255
}

private func toUInt8(_ x: Float) -> UInt8 {
  return UInt8(max(0, min(255, x * 255)).rounded())
}
