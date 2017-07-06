public enum Method: Value {
  case get
  case post

  public func render(with key: String) -> EncodedString? {
    switch self {
    case .get:
      return encode("method=") + quote(encode("GET"))
    case .post:
      return encode("method=") + quote(encode("POST"))
    }
  }
}

public func action(_ action: String) -> Attribute {
  return Attribute("action", action)
}

public func autofocus(_ autofocus: Bool) -> Attribute {
  return Attribute("autofocus", autofocus)
}

public func checked(_ checked: Bool) -> Attribute {
  return Attribute("checked", checked)
}

public func `class`(_ `class`: String) -> Attribute {
  return Attribute("class", `class`)
}

public func cols(_ cols: Int) -> Attribute {
  return Attribute("cols", cols)
}

public func disabled(_ disabled: Bool) -> Attribute {
  return Attribute("disabled", disabled)
}

public func `for`(_ `for`: String) -> Attribute {
  return Attribute("for", `for`)
}

public func href(_ href: String) -> Attribute {
  return Attribute("href", href)
}

public func id(_ id: String) -> Attribute {
  return Attribute("id", id)
}

public func height(_ height: Int) -> Attribute {
  return Attribute("height", height)
}

public func max(_ max: Int) -> Attribute {
  return Attribute("max", max)
}

public func maxlength(_ maxlength: Int) -> Attribute {
  return Attribute("maxlength", maxlength)
}

public func method(_ method: Method) -> Attribute {
  return Attribute("method", method)
}

public func min(_ min: Int) -> Attribute {
  return Attribute("min", min)
}

public func minlength(_ minlength: Int) -> Attribute {
  return Attribute("minlength", minlength)
}

public func multiple(_ multiple: Bool) -> Attribute {
  return Attribute("multiple", multiple)
}

public func name(_ name: String) -> Attribute {
  return Attribute("name", name)
}

public func novalidate(_ novalidate: Bool) -> Attribute {
  return Attribute("novalidate", novalidate)
}

public func pattern(_ pattern: String) -> Attribute {
  return Attribute("pattern", pattern)
}

public func placeholder(_ placeholder: String) -> Attribute {
  return Attribute("placeholder", placeholder)
}

public func readonly(_ readonly: Bool) -> Attribute {
  return Attribute("readonly", readonly)
}

public func required(_ required: Bool) -> Attribute {
  return Attribute("required", required)
}

public func rows(_ rows: Int) -> Attribute {
  return Attribute("rows", rows)
}

public func selected(_ selected: Bool) -> Attribute {
  return Attribute("selected", selected)
}

public func src(_ src: String) -> Attribute {
  return Attribute("src", src)
}

public func step(_ step: Int) -> Attribute {
  return Attribute("step", step)
}

public func style(_ style: String) -> Attribute {
  return Attribute("style", style)
}

public func type(_ type: String) -> Attribute {
  return Attribute("type", type)
}

public func value(_ value: String) -> Attribute {
  return Attribute("value", value)
}

public func width(_ width: Int) -> Attribute {
  return Attribute("width", width)
}
