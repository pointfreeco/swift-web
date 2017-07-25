import Prelude

public enum ColorVal: Val, Auto, Inherit, None {
  public static let auto: ColorVal = .other(.auto)
  public static let inherit: ColorVal = .other(.inherit)
  public static let none: ColorVal = .other(.none)

  case rgba(Color)
  case other(Value)

  public func value() -> Value {
    switch self {
    case let .rgba(color):
      return color.value()
    case let .other(value):
      return value
    }
  }
}

public struct Color {
  private(set) var red: Float {
    didSet {
      self.red = (clamped(0..<1) <| self.red)
    }
  }

  private(set) var blue: Float {
    didSet {
      self.blue = (clamped(0..<1) <| self.blue)
    }
  }

  private(set) var green: Float {
    didSet {
      self.green = (clamped(0..<1) <| self.green)
    }
  }

  private(set) var alpha: Float {
    didSet {
      self.alpha = (clamped(0..<1) <| self.alpha)
    }
  }

  public private(set) var hue: Int {
    get {
      return rgb2hsl(self.red, self.green, self.blue).hue
    }
    set(h) {
      let (_, s, l) = rgb2hsl(self.red, self.green, self.blue)
      (self.red, self.green, self.blue) = hsl2rgb(h, s, l)
    }
  }

  public private(set) var saturation: Float {
    get {
      return rgb2hsl(self.red, self.green, self.blue).saturation
    }
    set(s) {
      let (h, _, l) = rgb2hsl(self.red, self.green, self.blue)
      (self.red, self.green, self.blue) = hsl2rgb(h, s, l)
    }
  }

  public private(set) var lightness: Float {
    get {
      return rgb2hsl(self.red, self.green, self.blue).lightness
    }
    set(l) {
      let (h, s, _) = rgb2hsl(self.red, self.green, self.blue)
      (self.red, self.green, self.blue) = hsl2rgb(h, s, l)
    }
  }

  public init(red: Float, green: Float, blue: Float, alpha: Float = 1.0) {
    self.red = Float(clamped(0..<1) <| red)
    self.blue = Float(clamped(0..<1) <| blue)
    self.green = Float(clamped(0..<1) <| green)
    self.alpha = Float(clamped(0..<1) <| alpha)
  }

  public init(hue: Int, saturation: Float, lightness: Float, alpha: Float = 1.0) {
    let (r, g, b) = hsl2rgb(hue, saturation, lightness)
    self.init(red: r, green: g, blue: b, alpha: alpha)
  }
}

extension Color: _ExpressibleByColorLiteral {
  public init(_colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}

extension Color: Equatable {
  public static func ==(lhs: Color, rhs: Color) -> Bool {
    return toUInt8(lhs.red) == toUInt8(rhs.red)
      && toUInt8(lhs.blue) == toUInt8(rhs.blue)
      && toUInt8(lhs.green) == toUInt8(rhs.green)
      && toUInt8(lhs.alpha) == toUInt8(rhs.alpha)
  }
}

public func rgba(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: Float) -> Color {
  return Color(red: Float(r) / 255, green: Float(g) / 255, blue: Float(b) / 255, alpha: a)
}

public func rgb(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> Color {
  return rgba(r, g, b, 1)
}

public func hsla(_ h: Int, _ s: Float, _ l: Float, _ a: Float) -> Color {
  return Color(hue: h, saturation: s, lightness: l, alpha: a)
}

public func hsl(_ h: Int, _ s: Float, _ l: Float) -> Color {
  return hsla(h, s, l, 1)
}

public func white(_ w: Float, _ a: Float) -> Color {
  return .init(red: w, green: w, blue: w, alpha: a)
}

public let red = rgba(255, 0, 0, 1)
public let green = rgba(0, 255, 0, 1)
public let blue = rgba(0, 0, 255, 1)

extension Color: Val {
  public func value() -> Value {
    let (r, g, b) = (toUInt8(self.red), toUInt8(self.green), toUInt8(self.blue))
    let formatted = self.alpha == 1
      ? "#" + phex(r) + phex(g) + phex(b)
      : "rgba(\(r),\(g),\(b),\(self.alpha))"
    return .init(.plain(formatted))
  }
}

public func darken(_ by: Float) -> (Color) -> Color {
  return over(\Color.lightness) <| { $0 * (1 - by) }
}

public func lighten(_ by: Float) -> (Color) -> Color {
  return over(\Color.lightness) <| { $0 * (1 + by) }
}

public func saturate(_ by: Float) -> (Color) -> Color {
  return over(\Color.saturation) <| { $0 * (1 + by) }
}

public func desaturate(_ by: Float) -> (Color) -> Color {
  return over(\Color.saturation) <| { $0 * (1 - by) }
}

private func rgb2hsl(_ r: Float, _ g: Float, _ b: Float) -> (hue: Int, saturation: Float, lightness: Float) {
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

private func hsl2rgb(_ h: Int, _ s: Float, _ l: Float) -> (red: Float, green: Float, blue: Float) {
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

  return (r, g, b)
}

private func clamped<T>(_ to: Range<T>) -> (T) -> T {
  return { element in
    min(to.upperBound, max(to.lowerBound, element))
  }
}

private func phex(_ n: Int) -> String {
  return (n < 16 ? "0" : "") + String(n, radix: 16, uppercase: false)
}

private func toUInt8(_ x: Float) -> Int {
  return Int(max(0, min(255, x * 255)).rounded())
}
