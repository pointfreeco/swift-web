import Prelude

public struct BoxType: Val, Inherit {
  let boxType: Value

  public func value() -> Value {
    return self.boxType
  }

  public static let inherit = BoxType(boxType: .inherit)

  public static let paddingBox: BoxType = "padding-box"
  public static let borderBox: BoxType = "border-box"
  public static let contentBox: BoxType = "content-box"
}

extension BoxType: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(boxType: .init(stringLiteral: value))
  }
}

public func boxSizing(_ type: BoxType) -> Stylesheet {
  return prefixed(browsers <> "box-sizing", type)
}




//boxSizing :: BoxType -> Css
//boxSizing = prefixed (browsers <> "box-sizing")
//
//-------------------------------------------------------------------------------
//
//boxShadow :: Size a -> Size a -> Size a -> Color -> Css
//boxShadow x y w c = prefixed (browsers <> "box-shadow") (x ! y ! w ! c)
//
//boxShadowWithSpread :: Size a -> Size a -> Size a -> Size a -> Color -> Css
//boxShadowWithSpread x y blurRadius spreadRadius color =
//prefixed (browsers <> "box-shadow") (x ! y ! blurRadius ! spreadRadius ! color)
//
//boxShadows :: [(Size a, Size a, Size a, Color)] -> Css
//boxShadows = prefixed (browsers <> "box-shadow") . map (\(a, b, c, d) -> a ! b ! c ! d)
//
//-------------------------------------------------------------------------------
//
//insetBoxShadow :: Stroke -> Size a -> Size a -> Size a -> Color -> Css
//insetBoxShadow x y w c z = prefixed (browsers <> "box-shadow") (x ! y ! w ! c ! z)

extension Optional {
  func `do`(_ f: (Wrapped) -> Void) {
    guard let x = self else { return }
    f(x)
  }
}

func intersperse<A>(_ a: A) -> ([A]) -> [A] {
  return { xs in
    var result = [A]()
    for x in xs.dropLast() {
      result.append(x)
      result.append(a)
    }
    xs.last.do { result.append($0) }
    return result
  }
}

public func boxShadow(
  stroke: Stroke? = nil,
  x: Css.Size? = nil,
  y: Css.Size? = nil,
  blurRadius: Css.Size? = nil,
  spreadRadius: Css.Size? = nil,
  color: Color? = nil
  )
  ->
  Stylesheet {

    return prefixed(
      browsers <> "box-shadow",
      ([stroke, x, y, blurRadius, spreadRadius, color] as [Val?])
        |> catOptionals
        |> map({ Value($0.value().unValue) })
        |> intersperse(" ")
        |> concat
    )
}
