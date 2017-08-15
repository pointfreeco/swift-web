public struct ObjectFit: Val, Inherit, Initial, Unset, None {
  let objectFit: Value

  public func value() -> Value {
    return self.objectFit
  }

  public static let inherit = ObjectFit(objectFit: .inherit)
  public static let initial = ObjectFit(objectFit: .initial)
  public static let unset = ObjectFit(objectFit: .unset)
  public static let none = ObjectFit(objectFit: .none)

  public static let fill = ObjectFit(objectFit: "fill")
  public static let contain = ObjectFit(objectFit: "contain")
  public static let cover = ObjectFit(objectFit: "cover")
  public static let scaleDown = ObjectFit(objectFit: "scale-down")
}

public func objectFit(_ fit: ObjectFit) -> Stylesheet {
  return key("object-fit")(fit)
}
