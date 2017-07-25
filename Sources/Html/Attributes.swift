public func action(_ action: String) -> Attribute<Element.Form> {
  return .init("action", action)
}

public protocol HasAutofocus {}
public func autofocus<T: HasAutofocus>(_ autofocus: Bool) -> Attribute<T> {
  return .init("autofocus", autofocus)
}

public enum Charset: String {
  case utf8 = "utf-8"
  // TODO: add rest from here http://www.iana.org/assignments/character-sets/character-sets.xhtml
}

public protocol HasCharset {}
public func charset<T: HasCharset>(_ charset: Charset) -> Attribute<T> {
  return .init("charset", charset.rawValue)
}

public func checked(_ checked: Bool) -> Attribute<Element.Input> {
  return .init("checked", checked)
}

public func `class`<T>(_ `class`: String) -> Attribute<T> {
  return .init("class", `class`)
}

public func cols(_ cols: Int) -> Attribute<Element.Textarea> {
  return .init("cols", cols)
}

public func content(_ content: String) -> Attribute<Element.Meta> {
  return .init("content", content)
}

public protocol HasDisabled {}
public func disabled<T: HasDisabled>(_ disabled: Bool) -> Attribute<T> {
  return .init("disabled", disabled)
}

public protocol HasFor {}
public func `for`<T: HasFor>(_ `for`: String) -> Attribute<T> {
  return .init("for", `for`)
}

public protocol HasHref {}
public func href<T: HasHref>(_ href: String) -> Attribute<T> {
  return .init("href", href)
}

public func id<T>(_ id: String) -> Attribute<T> {
  return .init("id", id)
}

public protocol HasHeight {}
public func height<T: HasHeight>(_ height: Int) -> Attribute<T> {
  return .init("height", height)
}

public protocol HasMax {}
public func max<T: HasMax>(_ max: Int) -> Attribute<T> {
  return .init("max", max)
}

public protocol HasMaxlength {}
public func maxlength<T>(_ maxlength: Int) -> Attribute<T> {
  return .init("maxlength", maxlength)
}

public enum Method: String, Value {
  case get = "GET"
  case post = "POST"
}
public func method(_ method: Method) -> Attribute<Element.Form> {
  return .init("method", method)
}

public protocol HasMin {}
public func min<T: HasMin>(_ min: Int) -> Attribute<T> {
  return .init("min", min)
}

public protocol HasMinlength {}
public func minlength<T: HasMinlength>(_ minlength: Int) -> Attribute<T> {
  return .init("minlength", minlength)
}

public protocol HasMultiple {}
public func multiple<T: HasMultiple>(_ multiple: Bool) -> Attribute<T> {
  return .init("multiple", multiple)
}

public protocol HasName {}
public func name<T: HasName>(_ name: String) -> Attribute<T> {
  return .init("name", name)
}

public func novalidate(_ novalidate: Bool) -> Attribute<Element.Form> {
  return .init("novalidate", novalidate)
}

public func pattern(_ pattern: String) -> Attribute<Element.Input> {
  return .init("pattern", pattern)
}

public protocol HasPlaceholder {}
public func placeholder<T: HasPlaceholder>(_ placeholder: String) -> Attribute<T> {
  return .init("placeholder", placeholder)
}

public protocol HasReadonly {}
public func readonly<T>(_ readonly: Bool) -> Attribute<T> {
  return .init("readonly", readonly)
}

public protocol HasRel {}
public func rel<T: HasRel>(_ rel: String) -> Attribute<T> {
  return .init("rel", rel)
}

public protocol HasRequired {}
public func required<T: HasRequired>(_ required: Bool) -> Attribute<T> {
  return .init("required", required)
}

public func rows(_ rows: Int) -> Attribute<Element.Textarea> {
  return .init("rows", rows)
}

public func selected(_ selected: Bool) -> Attribute<Element.Option> {
  return .init("selected", selected)
}

public protocol HasSrc {}
public func src<T: HasSrc>(_ src: String) -> Attribute<T> {
  return .init("src", src)
}

public func step(_ step: Int) -> Attribute<Element.Input> {
  return .init("step", step)
}

public func style<T>(_ style: String) -> Attribute<T> {
  return .init("style", style)
}

public enum Target: Value {
  case blank
  case `self`
  case parent
  case top
  case frame(named: String)

  public func renderedValue() -> EncodedString? {
    return encode(self.description)
  }

  public var description: String {
    switch self {
    case .blank:
      return "_blank"
    case .self:
      return "_self"
    case .parent:
      return "_parent"
    case .top:
      return "_top"
    case .frame(let name):
      return name
    }
  }
}
public protocol HasTarget {}
public func target<T: HasTarget>(_ target: Target) -> Attribute<T> {
  return .init("target", target)
}

// TODO: type as media type
public protocol HasMediaType {}
public func type<T: HasMediaType>(_ type: String) -> Attribute<T> {
  return .init("type", type)
}

public enum ButtonType: String, Value {
  case button
  case reset
  case submit
}
public func type(_ type: ButtonType) -> Attribute<Element.Button> {
  return .init("type", type)
}

public enum InputType: String, Value {
  case button
  case checkbox
  case color
  case date
  case datetimeLocal = "datetime-local"
  case email
  case file
  case hidden
  case image
  case month
  case number
  case password
  case radio
  case range
  case reset
  case search
  case submit
  case tel
  case text
  case time
  case url
  case week
}
public func type(_ type: InputType) -> Attribute<Element.Input> {
  return .init("type", type)
}

public enum MenuType: String, Value {
  case list
  case context
  case toolbar
}
public func type(_ type: MenuType) -> Attribute<Element.Menu> {
  return .init("type", type)
}

public protocol HasValue {}
public func value<T: HasValue>(_ value: String) -> Attribute<T> {
  return .init("value", value)
}

public func value(_ value: Double) -> Attribute<Element.Progress> {
  return .init("value", value)
}

public protocol HasWidth {}
public func width<T: HasWidth>(_ width: Int) -> Attribute<T> {
  return .init("width", width)
}

public enum Wrap: String, Value {
  case hard
  case soft
}
public func wrap(_ wrap: Wrap) -> Attribute<Element.Textarea> {
  return .init("wrap", wrap)
}
