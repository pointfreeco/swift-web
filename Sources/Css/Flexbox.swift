import Prelude

public protocol FlexEnd {
  static var flexEnd: Self { get }
}

public protocol FlexStart {
  static var flexStart: Self { get }
}

public protocol SpaceAround {
  static var spaceAround: Self { get }
}

public protocol SpaceBetween {
  static var spaceBetween: Self { get }
}

public protocol Stretch {
  static var stretch: Self { get }
}

extension Value: FlexStart, FlexEnd, SpaceAround, SpaceBetween, Stretch {
  public static let flexEnd = Value(stringLiteral: "flex-end")
  public static let flexStart = Value(stringLiteral: "flex-start")
  public static let spaceAround = Value(stringLiteral: "space-around")
  public static let spaceBetween = Value(stringLiteral: "space-between")
  public static let stretch = Value(stringLiteral: "stretch")
}

public struct AlignContent: Val, Other, Inherit, FlexStart, FlexEnd, Center, SpaceBetween, SpaceAround, Stretch {
  let alignContent: Value

  public static let inherit = AlignContent(alignContent: .inherit)
  public static let center = AlignContent(alignContent: .center)

  public static func other(_ other: Value) -> AlignContent {
    return .init(alignContent: other)
  }

  public static let stretch = AlignContent(alignContent: .stretch)
  public static let flexStart = AlignContent(alignContent: .flexStart)
  public static let flexEnd = AlignContent(alignContent: .flexEnd)
  public static let spaceBetween = AlignContent(alignContent: .spaceBetween)
  public static let spaceAround = AlignContent(alignContent: .spaceAround)

  public func value() -> Value {
    return self.alignContent
  }
}

public struct AlignItems: Val, Other, Inherit, Baseline, FlexStart, FlexEnd, Center, Stretch {
  let alignItems: Value

  public static let inherit = AlignItems(alignItems: .inherit)
  public static let center = AlignItems(alignItems: .center)
  public static let baseline = AlignItems(alignItems: .baseline)

  public static func other(_ other: Value) -> AlignItems {
    return .init(alignItems: other)
  }

  public static let stretch = AlignItems(alignItems: .stretch)
  public static let flexStart = AlignItems(alignItems: .flexStart)
  public static let flexEnd = AlignItems(alignItems: .flexEnd)

  public func value() -> Value {
    return self.alignItems
  }
}

public struct AlignSelf: Val, Other, Inherit, Auto, Baseline, FlexStart, FlexEnd, Center, Stretch {
  let alignSelf: Value

  public static let inherit = AlignSelf(alignSelf: .inherit)
  public static let center = AlignSelf(alignSelf: .center)
  public static let baseline = AlignSelf(alignSelf: .baseline)
  public static let auto = AlignSelf(alignSelf: .auto)

  public static func other(_ other: Value) -> AlignSelf {
    return .init(alignSelf: other)
  }

  public static let stretch = AlignSelf(alignSelf: .stretch)
  public static let flexStart = AlignSelf(alignSelf: .flexStart)
  public static let flexEnd = AlignSelf(alignSelf: .flexEnd)

  public func value() -> Value {
    return self.alignSelf
  }
}

public struct JustifyContent: Val, Other, Inherit, FlexStart, FlexEnd, Center, SpaceAround, SpaceBetween {
  let justifyContent: Value

  public static let inherit = JustifyContent(justifyContent: .inherit)
  public static let auto = JustifyContent(justifyContent: .auto)
  public static let center = JustifyContent(justifyContent: .center)

  public static func other(_ other: Value) -> JustifyContent {
    return .init(justifyContent: other)
  }

  public static let flexStart = JustifyContent(justifyContent: .flexStart)
  public static let flexEnd = JustifyContent(justifyContent: .flexEnd)
  public static let spaceAround = JustifyContent(justifyContent: .spaceAround)
  public static let spaceBetween = JustifyContent(justifyContent: .spaceBetween)

  public func value() -> Value {
    return self.justifyContent
  }
}

public struct FlexDirection: Val, Other {
  let flexDirection: Value

  public static func other(_ other: Value) -> FlexDirection {
    return .init(flexDirection: other)
  }

  public func value() -> Value {
    return self.flexDirection
  }

  public static let row = FlexDirection(flexDirection: "row")
  public static let rowReverse = FlexDirection(flexDirection: "row-reverse")
  public static let column = FlexDirection(flexDirection: "column")
  public static let columnReverse = FlexDirection(flexDirection: "column-reverse")
}

public struct FlexWrap: Val, Other {
  let flexWrap: Value

  public static func other(_ other: Value) -> FlexWrap {
    return .init(flexWrap: other)
  }

  public func value() -> Value {
    return self.flexWrap
  }

  public static let nowrap = FlexWrap(flexWrap: "nowrap")
  public static let wrap = FlexWrap(flexWrap: "wrap")
  public static let wrapReverse = FlexWrap(flexWrap: "wrap-reverse")
}

public func flex(
  grow: Int? = nil,
  shrink: Int? = nil,
  basis: Size? = nil
  )
  ->
  Stylesheet {

    return [
      grow.map(key("flex-grow")),
      shrink.map(key("flex-shrink")),
      basis.map(key("flex-basis"))
      ]
      |> catOptionals
      |> concat
}

public func flex(
  direction: FlexDirection? = nil,
  wrap: FlexWrap? = nil
  )
  ->
  Stylesheet {

    return [
      direction.map(key("flex-direction")),
      wrap.map(key("flex-wrap")),
      ]
      |> catOptionals
      |> concat
}

public func align(
  content: AlignContent? = nil,
  items: AlignItems? = nil,
  self: AlignSelf? = nil
  )
  ->
  Stylesheet {

    return [
      content.map(key("align-content")),
      items.map(key("align-items")),
      self.map(key("align-self"))
      ]
      |> catOptionals
      |> concat
}

public func order(_ order: Int) -> Stylesheet {
  return key("order", order)
}

public func justify(content justifyContent: JustifyContent) -> Stylesheet {
  return key("justify-content", justifyContent)
}

