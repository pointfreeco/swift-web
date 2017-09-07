import Foundation
import MediaType
import Prelude

public typealias Id = String

public func abbr(_ value: String) -> Attribute<Element.Th> {
  return .init("abbr", value)
}

public func accesskey<T>(_ value: String) -> Attribute<T> {
  return .init("accesskey", value)
}

public func action(_ value: String) -> Attribute<Element.Form> {
  return .init("action", value)
}

public protocol HasAlt {}
public func alt<T: HasAlt>(_ value: String) -> Attribute<T> {
  return .init("alt", value)
}

public protocol HasAutofocus {}
public func autofocus<T: HasAutofocus>(_ value: Bool) -> Attribute<T> {
  return .init("autofocus", value)
}

public protocol HasAutoplay {}
public func autoplay<T: HasAutoplay>(_ value: Bool) -> Attribute<T> {
  return .init("autoplay", value)
}

extension Charset: Value {}
public protocol HasCharset {}
public func charset<T: HasCharset>(_ value: Charset) -> Attribute<T> {
  return .init("charset", value)
}

public func checked(_ value: Bool) -> Attribute<Element.Input> {
  return .init("checked", value)
}

public protocol HasCite {}
public func cite<T: HasCite>(_ value: String) -> Attribute<T> {
  return .init("cite", value)
}

public func `class`<T>(_ value: String) -> Attribute<T> {
  return .init("class", value)
}

public func cols(_ value: Int) -> Attribute<Element.Textarea> {
  return .init("cols", value)
}

public protocol HasColspan {}
public func colspan<T: HasColspan>(_ value: Int) -> Attribute<T> {
  return .init("colspan", value)
}

public func content(_ value: String) -> Attribute<Element.Meta> {
  return .init("content", value)
}

public func contenteditable<T>(_ value: String) -> Attribute<T> {
  return .init("contenteditable", value)
}

public protocol HasControls {}
public func controls<T: HasControls>(_ value: Bool) -> Attribute<T> {
  return .init("controls", value)
}

public enum Crossorigin: String, Value {
  case anonymous
  case useCredentials = "use-credentials"
}
public protocol HasCrossorigin {}
public func crossorigin<T: HasCrossorigin>(_ value: Crossorigin) -> Attribute<T> {
  return .init("crossorigin", value)
}

private let iso8601DateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
  return formatter
}()
extension Date: Value {
  public func renderedValue() -> EncodedString? {
    return Html.encode(iso8601DateFormatter.string(from: self))
  }
}
public protocol HasDatetime {}
public func datetime<T: HasDatetime>(_ value: Date) -> Attribute<T> {
  return .init("datetime", value)
}

public func `default`(_ value: Bool) -> Attribute<Element.Track> {
  return .init("default", value)
}

public enum Direction: String, Value {
  case ltr
  case rtl
  case auto
}
public func dir<T>(_ value: Direction) -> Attribute<T> {
  return .init("dir", value)
}

public protocol HasDisabled {}
public func disabled<T: HasDisabled>(_ value: Bool) -> Attribute<T> {
  return .init("disabled", value)
}

public enum Draggable: String, Value {
  case `true`
  case `false`
  case auto
}
extension Draggable: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    if value {
      self = .true
    } else {
      self = .false
    }
  }
}
public func draggable<T>(_ value: Draggable) -> Attribute<T> {
  return .init("draggable", value)
}

public enum Dropzone: String, Value {
  case copy
  case move
  case link
}
public func dropzone<T>(_ value: Dropzone) -> Attribute<T> {
  return .init("dropzone", value)
}

public protocol HasFor {}
public func `for`<T: HasFor>(_ value: Id) -> Attribute<T> {
  return .init("for", value)
}

public protocol HasForm {}
public func form<T: HasForm>(_ value: Id) -> Attribute<T> {
  return .init("form", value)
}

public protocol HasHeaders {}
public func headers<T: HasHeaders>(_ value: Id) -> Attribute<T> {
  return .init("headers", value)
}

public protocol HasHeight {}
public func height<T: HasHeight>(_ value: Int) -> Attribute<T> {
  return .init("height", value)
}

public func hidden<T>(_ value: Bool) -> Attribute<T> {
  return .init("hidden", value)
}

public protocol HasHref {}
public func href<T: HasHref>(_ value: String) -> Attribute<T> {
  return .init("href", value)
}

public enum HttpEquiv: String, Value {
  case contentType = "content-type"
  case defaultStyle = "default-style"
  case refresh = "refresh"
}
public func httpEquiv(_ value: HttpEquiv) -> Attribute<Element.Meta> {
  return .init("http-equiv", value)
}

public func id<T>(_ value: Id) -> Attribute<T> {
  return .init("id", value)
}

public enum Kind: String, Value {
  case captions
  case chapters
  case descriptions
  case metadata
  case subtitles
}
public func kind(_ value: Kind) -> Attribute<Element.Track> {
  return .init("kind", value)
}

public func label(_ value: String) -> Attribute<Element.Track> {
  return .init("label", value)
}

public enum Language: String, Value {
  case aa
  case ab
  case ae
  case af
  case ak
  case am
  case an
  case ar
  case `as`
  case av
  case ay
  case az
  case ba
  case be
  case bg
  case bh
  case bi
  case bm
  case bn
  case bo
  case br
  case bs
  case ca
  case ce
  case ch
  case co
  case cr
  case cs
  case cu
  case cv
  case cy
  case da
  case de
  case dv
  case dz
  case ee
  case el
  case en
  case eo
  case es
  case et
  case eu
  case fa
  case ff
  case fi
  case fj
  case fo
  case fr
  case fy
  case ga
  case gd
  case gl
  case gn
  case gu
  case gv
  case ha
  case he
  case hi
  case ho
  case hr
  case ht
  case hu
  case hy
  case hz
  case ia
  case id
  case ie
  case ig
  case ii
  case ik
  case `in`
  case io
  case `is`
  case it
  case iu
  case ja
  case ji
  case jv
  case ka
  case kg
  case ki
  case kj
  case kk
  case kl
  case km
  case kn
  case ko
  case kr
  case ks
  case ku
  case kv
  case kw
  case ky
  case la
  case lb
  case lg
  case li
  case ln
  case lo
  case lt
  case lu
  case lv
  case mg
  case mh
  case mi
  case mk
  case ml
  case mn
  case mr
  case ms
  case mt
  case my
  case na
  case nb
  case nd
  case ne
  case nl
  case nn
  case no
  case nr
  case nv
  case ny
  case oc
  case oj
  case om
  case or
  case os
  case pa
  case pi
  case pl
  case ps
  case pt
  case qu
  case rm
  case rn
  case ro
  case ru
  case rw
  case sa
  case sc
  case sd
  case se
  case sg
  case si
  case sk
  case sl
  case sm
  case sn
  case so
  case sq
  case sr
  case ss
  case st
  case su
  case sv
  case sw
  case ta
  case te
  case tg
  case th
  case ti
  case tk
  case tl
  case tn
  case to
  case tr
  case ts
  case tt
  case tw
  case ty
  case ug
  case uk
  case ur
  case uz
  case ve
  case vi
  case vo
  case wa
  case wo
  case xh
  case yi
  case yo
  case za
  case zu
  case zh
  case zhHans = "zh-Hans"
  case zhHant = "zh-Hant"
}
public func lang<T>(_ value: Language) -> Attribute<T> {
  return .init("lang", value)
}

public protocol HasLoop {}
public func loop<T: HasLoop>(_ value: Bool) -> Attribute<T> {
  return .init("loop", value)
}

public protocol HasMax {}
public func max<T: HasMax>(_ value: Double) -> Attribute<T> {
  return .init("max", value)
}

public protocol HasMaxlength {}
public func maxlength<T>(_ value: Int) -> Attribute<T> {
  return .init("maxlength", value)
}

// TODO: Add direct media query support to HtmlCssSupport
public func media(_ value: String) -> Attribute<Element.Source> {
  return .init("media", value)
}

public enum Method: String, Value {
  case get = "GET"
  case post = "POST"
}
public func method(_ value: Method) -> Attribute<Element.Form> {
  return .init("method", value)
}

public protocol HasMin {}
public func min<T: HasMin>(_ value: Double) -> Attribute<T> {
  return .init("min", value)
}

public protocol HasMinlength {}
public func minlength<T: HasMinlength>(_ value: Int) -> Attribute<T> {
  return .init("minlength", value)
}

public protocol HasMultiple {}
public func multiple<T: HasMultiple>(_ value: Bool) -> Attribute<T> {
  return .init("multiple", value)
}

public protocol HasMuted {}
public func muted<T: HasMuted>(_ value: Bool) -> Attribute<T> {
  return .init("muted", value)
}

public protocol HasName {}
public func name<T: HasName>(_ value: String) -> Attribute<T> {
  return .init("name", value)
}

public enum MetaName: String, Value {
  case applicationName = "application-name"
  case author
  case description
  case generator
  case keywords
  // ...
  case viewport
}
public func name(_ value: MetaName) -> Attribute<Element.Meta> {
  return .init("name", value)
}

public func novalidate(_ value: Bool) -> Attribute<Element.Form> {
  return .init("novalidate", value)
}

public func open(_ value: Bool) -> Attribute<Element.Details> {
  return .init("open", value)
}

public func pattern(_ value: String) -> Attribute<Element.Input> {
  return .init("pattern", value)
}

public protocol HasPlaceholder {}
public func placeholder<T: HasPlaceholder>(_ value: String) -> Attribute<T> {
  return .init("placeholder", value)
}

public enum Preload: String, Value {
  case auto
  case metadata
  case none
}
public protocol HasPreload {}
public func preload<T: HasPreload>(_ value: Preload) -> Attribute<T> {
  return .init("preload", value)
}

public protocol HasReadonly {}
public func readonly<T: HasReadonly>(_ value: Bool) -> Attribute<T> {
  return .init("readonly", value)
}

public enum Rel: CustomStringConvertible, Value {
  case alternate
  case author
  case bookmark
  case help
  case icon
  case license
  case next
  case nofollow
  case noreferrer
  case prev
  case search
  case stylesheet
  case tag
  case other(String)

  public var description: String {
    switch self {
    case .alternate:
      return "alternate"
    case .author:
      return "author"
    case .bookmark:
      return "bookmark"
    case .help:
      return "help"
    case .icon:
      return "icon"
    case .license:
      return "license"
    case .next:
      return "next"
    case .nofollow:
      return "nofollow"
    case .noreferrer:
      return "noreferrer"
    case .prev:
      return "prev"
    case .search:
      return "search"
    case .stylesheet:
      return "stylesheet"
    case .tag:
      return "tag"
    case let .other(string):
      return string
    }
  }
}
public protocol HasRel {}
public func rel<T: HasRel>(_ value: Rel) -> Attribute<T> {
  return .init("rel", value)
}

public protocol HasRequired {}
public func required<T: HasRequired>(_ value: Bool) -> Attribute<T> {
  return .init("required", value)
}

public func rows(_ value: Int) -> Attribute<Element.Textarea> {
  return .init("rows", value)
}

public protocol HasRowspan {}
public func rowspan<T: HasRowspan>(_ value: Int) -> Attribute<T> {
  return .init("rowspan", value)
}

public enum Sandbox: String {
  case allowForms = "allow-forms"
  case allowPointerLock = "allow-pointer-lock"
  case allowPopups = "allow-popups"
  case allowSameOrigin = "allow-same-origin"
  case allowScripts = "allow-scripts"
  case allowTopNavigation = "allow-top-navigation"
}
public func sandbox(_ value: [Sandbox]) -> Attribute<Element.Iframe> {
  return .init("sandbox", value.map(get(\.rawValue)).joined(separator: " "))
}

public enum Scope: String, Value {
  case col
  case colgroup
  case row
  case rowgroup
}
public func scope(_ value: Bool) -> Attribute<Element.Th> {
  return .init("scope", value)
}

public func selected(_ value: Bool) -> Attribute<Element.Option> {
  return .init("selected", value)
}

public protocol HasSpan {}
public func span<T: HasSpan>(_ value: Int) -> Attribute<T> {
  return .init("span", String(value))
}

public func spellcheck<T>(_ value: Bool) -> Attribute<T> {
  return .init("spellcheck", String(value))
}

public protocol HasSrc {}
public func src<T: HasSrc>(_ value: String) -> Attribute<T> {
  return .init("src", value)
}

public func srcdoc(_ value: Node) -> Attribute<Element.Iframe> {
  return .init("srcdoc", render(value))
}

public func srclang(_ value: Language) -> Attribute<Element.Track> {
  return .init("srclang", value)
}

public enum Size: CustomStringConvertible, Value {
  case w(Int)
  case x(Int)

  public var description: String {
    switch self {
    case let .w(n):
      return "\(n)w"
    case let .x(n):
      return "\(n)x"
    }
  }
}
public protocol HasSrcset {}
public func srcset<T: HasSrcset>(_ value: [String: Size]) -> Attribute<T> {
  return .init("srcset", value.map { url, size in "\(url) \(size)" }.joined(separator: ", "))
}

public func srcset(_ value: String) -> Attribute<Element.Source> {
  return .init("srcset", value)
}

public func step(_ value: Int) -> Attribute<Element.Input> {
  return .init("step", value)
}

public func style<T>(_ value: String) -> Attribute<T> {
  return .init("style", value)
}

public func tabindex<T>(_ value: Int) -> Attribute<T> {
  return .init("tabindex", value)
}

public enum Target: Value, CustomStringConvertible {
  case blank
  case `self`
  case parent
  case top
  case frame(named: String)

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
public func target<T: HasTarget>(_ value: Target) -> Attribute<T> {
  return .init("target", value)
}

public func title<T>(_ value: String) -> Attribute<T> {
  return .init("title", value)
}

public enum Translate: String, Value {
  case yes
  case no
}
extension Translate: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    if value {
      self = .yes
    } else {
      self = .no
    }
  }
}
public func translate<T>(_ value: Translate) -> Attribute<T> {
  return .init("translate", value)
}

extension MediaType: Value {}
public protocol HasMediaType {}
public func type<T: HasMediaType>(_ value: MediaType) -> Attribute<T> {
  return .init("type", value)
}

public enum ButtonType: String, Value {
  case button
  case reset
  case submit
}
public func type(_ value: ButtonType) -> Attribute<Element.Button> {
  return .init("type", value)
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
public func type(_ value: InputType) -> Attribute<Element.Input> {
  return .init("type", value)
}

public protocol HasStringValue {}
public func value<T: HasStringValue>(_ value: String) -> Attribute<T> {
  return .init("value", value)
}

public protocol HasDoubleValue {}
public func value<T: HasDoubleValue>(_ value: Double) -> Attribute<T> {
  return .init("value", value)
}

public protocol HasWidth {}
public func width<T: HasWidth>(_ value: Int) -> Attribute<T> {
  return .init("width", value)
}

public enum Wrap: String, Value {
  case hard
  case soft
}
public func wrap(_ value: Wrap) -> Attribute<Element.Textarea> {
  return .init("wrap", value)
}
