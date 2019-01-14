import Prelude

public enum Color: Val, Inherit, Initial {
  case rgba(UInt8, UInt8, UInt8, Float)
  case other(Value)

  public func value() -> Value {
    switch self {
    case let .rgba(red, green, blue, alpha):
      let formatted: String = alpha == 1.0
        ? "#\(phex(red))\(phex(green))\(phex(blue))"
        : "rgba(\(red),\(green),\(blue),\(alpha))"
      return .init(.plain(formatted))
    case let .other(value):
      return value
    }
  }

  public static let inherit: Color = .other(.inherit)
  public static let initial: Color = .other(.initial)
  public static let transparent: Color = .other("transparent")

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
}

extension Color {
  public static let aliceblue = rgb(240, 248, 255)
  public static let antiquewhite = rgb(250, 235, 215)
  public static let aqua = rgb(0, 255, 255)
  public static let aquamarine = rgb(127, 255, 212)
  public static let azure = rgb(240, 255, 255)
  public static let beige = rgb(245, 245, 220)
  public static let bisque = rgb(255, 228, 196)
  public static let black = rgb(0, 0, 0)
  public static let blanchedalmond = rgb(255, 235, 205)
  public static let blue = rgb(0, 0, 255)
  public static let blueviolet = rgb(138, 43, 226)
  public static let brown = rgb(165, 42, 42)
  public static let burlywood = rgb(222, 184, 135)
  public static let cadetblue = rgb(95, 158, 160)
  public static let chartreuse = rgb(127, 255, 0)
  public static let chocolate = rgb(210, 105, 30)
  public static let coral = rgb(255, 127, 80)
  public static let cornflowerblue = rgb(100, 149, 237)
  public static let cornsilk = rgb(255, 248, 220)
  public static let crimson = rgb(220, 20, 60)
  public static let cyan = rgb(0, 255, 255)
  public static let darkblue = rgb(0, 0, 139)
  public static let darkcyan = rgb(0, 139, 139)
  public static let darkgoldenrod = rgb(184, 134, 11)
  public static let darkgray = rgb(169, 169, 169)
  public static let darkgreen = rgb(0, 100, 0)
  public static let darkgrey = rgb(169, 169, 169)
  public static let darkkhaki = rgb(189, 183, 107)
  public static let darkmagenta = rgb(139, 0, 139)
  public static let darkolivegreen = rgb(85, 107, 47)
  public static let darkorange = rgb(255, 140, 0)
  public static let darkorchid = rgb(153, 50, 204)
  public static let darkred = rgb(139, 0, 0)
  public static let darksalmon = rgb(233, 150, 122)
  public static let darkseagreen = rgb(143, 188, 143)
  public static let darkslateblue = rgb(72, 61, 139)
  public static let darkslategray = rgb(47, 79, 79)
  public static let darkslategrey = rgb(47, 79, 79)
  public static let darkturquoise = rgb(0, 206, 209)
  public static let darkviolet = rgb(148, 0, 211)
  public static let deeppink = rgb(255, 20, 147)
  public static let deepskyblue = rgb(0, 191, 255)
  public static let dimgray = rgb(105, 105, 105)
  public static let dimgrey = rgb(105, 105, 105)
  public static let dodgerblue = rgb(30, 144, 255)
  public static let firebrick = rgb(178, 34, 34)
  public static let floralwhite = rgb(255, 250, 240)
  public static let forestgreen = rgb(34, 139, 34)
  public static let fuchsia = rgb(255, 0, 255)
  public static let gainsboro = rgb(220, 220, 220)
  public static let ghostwhite = rgb(248, 248, 255)
  public static let gold = rgb(255, 215, 0)
  public static let goldenrod = rgb(218, 165, 32)
  public static let gray = rgb(128, 128, 128)
  public static let green = rgb(0, 128, 0)
  public static let greenyellow = rgb(173, 255, 47)
  public static let grey = rgb(128, 128, 128)
  public static let honeydew = rgb(240, 255, 240)
  public static let hotpink = rgb(255, 105, 180)
  public static let indianred = rgb(205, 92, 92)
  public static let indigo = rgb(75, 0, 130)
  public static let ivory = rgb(255, 255, 240)
  public static let khaki = rgb(240, 230, 140)
  public static let lavender = rgb(230, 230, 250)
  public static let lavenderblush = rgb(255, 240, 245)
  public static let lawngreen = rgb(124, 252, 0)
  public static let lemonchiffon = rgb(255, 250, 205)
  public static let lightblue = rgb(173, 216, 230)
  public static let lightcoral = rgb(240, 128, 128)
  public static let lightcyan = rgb(224, 255, 255)
  public static let lightgoldenrodyellow = rgb(250, 250, 210)
  public static let lightgray = rgb(211, 211, 211)
  public static let lightgreen = rgb(144, 238, 144)
  public static let lightgrey = rgb(211, 211, 211)
  public static let lightpink = rgb(255, 182, 193)
  public static let lightsalmon = rgb(255, 160, 122)
  public static let lightseagreen = rgb(32, 178, 170)
  public static let lightskyblue = rgb(135, 206, 250)
  public static let lightslategray = rgb(119, 136, 153)
  public static let lightslategrey = rgb(119, 136, 153)
  public static let lightsteelblue = rgb(176, 196, 222)
  public static let lightyellow = rgb(255, 255, 224)
  public static let lime = rgb(0, 255, 0)
  public static let limegreen = rgb(50, 205, 50)
  public static let linen = rgb(250, 240, 230)
  public static let magenta = rgb(255, 0, 255)
  public static let maroon = rgb(128, 0, 0)
  public static let mediumaquamarine = rgb(102, 205, 170)
  public static let mediumblue = rgb(0, 0, 205)
  public static let mediumorchid = rgb(186, 85, 211)
  public static let mediumpurple = rgb(147, 112, 219)
  public static let mediumseagreen = rgb(60, 179, 113)
  public static let mediumslateblue = rgb(123, 104, 238)
  public static let mediumspringgreen = rgb(0, 250, 154)
  public static let mediumturquoise = rgb(72, 209, 204)
  public static let mediumvioletred = rgb(199, 21, 133)
  public static let midnightblue = rgb(25, 25, 112)
  public static let mintcream = rgb(245, 255, 250)
  public static let mistyrose = rgb(255, 228, 225)
  public static let moccasin = rgb(255, 228, 181)
  public static let navajowhite = rgb(255, 222, 173)
  public static let navy = rgb(0, 0, 128)
  public static let oldlace = rgb(253, 245, 230)
  public static let olive = rgb(128, 128, 0)
  public static let olivedrab = rgb(107, 142, 35)
  public static let orange = rgb(255, 165, 0)
  public static let orangered = rgb(255, 69, 0)
  public static let orchid = rgb(218, 112, 214)
  public static let palegoldenrod = rgb(238, 232, 170)
  public static let palegreen = rgb(152, 251, 152)
  public static let paleturquoise = rgb(175, 238, 238)
  public static let palevioletred = rgb(219, 112, 147)
  public static let papayawhip = rgb(255, 239, 213)
  public static let peachpuff = rgb(255, 218, 185)
  public static let peru = rgb(205, 133, 63)
  public static let pink = rgb(255, 192, 203)
  public static let plum = rgb(221, 160, 221)
  public static let powderblue = rgb(176, 224, 230)
  public static let purple = rgb(128, 0, 128)
  public static let rebeccapurple = rgb(102, 51, 153)
  public static let red = rgb(255, 0, 0)
  public static let rosybrown = rgb(188, 143, 143)
  public static let royalblue = rgb(65, 105, 225)
  public static let saddlebrown = rgb(139, 69, 19)
  public static let salmon = rgb(250, 128, 114)
  public static let sandybrown = rgb(244, 164, 96)
  public static let seagreen = rgb(46, 139, 87)
  public static let seashell = rgb(255, 245, 238)
  public static let sienna = rgb(160, 82, 45)
  public static let silver = rgb(192, 192, 192)
  public static let skyblue = rgb(135, 206, 235)
  public static let slateblue = rgb(106, 90, 205)
  public static let slategray = rgb(112, 128, 144)
  public static let slategrey = rgb(112, 128, 144)
  public static let snow = rgb(255, 250, 250)
  public static let springgreen = rgb(0, 255, 127)
  public static let steelblue = rgb(70, 130, 180)
  public static let tan = rgb(210, 180, 140)
  public static let teal = rgb(0, 128, 128)
  public static let thistle = rgb(216, 191, 216)
  public static let tomato = rgb(255, 99, 71)
  public static let turquoise = rgb(64, 224, 208)
  public static let violet = rgb(238, 130, 238)
  public static let wheat = rgb(245, 222, 179)
  public static let white = rgb(255, 255, 255)
  public static let whitesmoke = rgb(245, 245, 245)
  public static let yellow = rgb(255, 255, 0)
  public static let yellowgreen = rgb(154, 205, 50)
}

extension Color: _ExpressibleByColorLiteral {
  public init(_colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
    self = .rgba(toUInt8(red), toUInt8(green), toUInt8(blue), alpha)
  }

  // TODO: Remove. Pre-Xcode 9 beta 4
  public init(colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
    self = .rgba(toUInt8(red), toUInt8(green), toUInt8(blue), alpha)
  }
}

extension Color {
  public var red: UInt8? {
    get {
      guard case let .rgba(r, _, _, _) = self else { return nil }
      return r
    }
    set(r) {
      guard let r = r, case let .rgba(_, g, b, a) = self else { return }
      self = .rgba(r, g, b, a)
    }
  }

  public var green: UInt8? {
    get {
      guard case let .rgba(r, _, _, _) = self else { return nil }
      return r
    }
    set(r) {
      guard let r = r, case let .rgba(_, g, b, a) = self else { return }
      self = .rgba(r, g, b, a)
    }
  }

  public var blue: UInt8? {
    get {
      guard case let .rgba(r, _, _, _) = self else { return nil }
      return r
    }
    set(r) {
      guard let r = r, case let .rgba(_, g, b, a) = self else { return }
      self = .rgba(r, g, b, a)
    }
  }

  public var alpha: Float? {
    get {
      guard case let .rgba(_, _, _, a) = self else { return nil }
      return a
    }
    set(a) {
      guard let a = a, case let .rgba(r, g, b, _) = self else { return }
      self = .rgba(r, g, b, a)
    }
  }

  public var hue: Int? {
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

  public var saturation: Float? {
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

  public var lightness: Float? {
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
