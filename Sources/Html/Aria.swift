import Prelude

public enum Role: String {
  case alert
  case alertdialog
  case application
  case article
  case banner
  case button
  case cell
  case checkbox
  case columnheader
  case combobox
  case complementary
  case contentinfo
  case definition
  case dialog
  case directory
  case document
  case feed
  case figure
  case form
  case grid
  case gridcell
  case group
  case heading
  case img
  case link
  case list
  case listbox
  case listitem
  case log
  case main
  case marquee
  case math
  case menu
  case menubar
  case menuitem
  case menuitemcheckbox
  case menuitemradio
  case navigation
  case none
  case note
  case option
  case presentation
  case progressbar
  case radio
  case radiogroup
  case region
  case row
  case rowgroup
  case rowheader
  case scrollbar
  case search
  case searchbox
  case separator
  case slider
  case spinbutton
  case status
  case `switch`
  case tab
  case table
  case tablist
  case tabpanel
  case term
  case textbox
  case timer
  case toolbar
  case tooltip
  case tree
  case treegrid
  case treeitem
}
public func role<T>(_ value: Role) -> Attribute<T> {
  return .init("role", value.rawValue)
}

public enum AriaBoolean: String {
  case `false`
  case `true`
  case undefined
}
extension AriaBoolean: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    if value {
      self = .true
    } else {
      self = .false
    }
  }
}

public enum AriaToggled: String {
  case `false`
  case `true`
  case mixed
  case undefined
}
extension AriaToggled: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    if value {
      self = .true
    } else {
      self = .false
    }
  }
}

public func ariaActivedescendant<T>(_ value: Id) -> Attribute<T> {
  return .init("aria-activedescendant", value)
}

public func ariaAtomic<T>(_ value: Bool) -> Attribute<T> {
  return .init("aria-atomic", String(value))
}

public enum AriaAutocomplete: String {
  case both
  case inline
  case list
  case none
}
public func ariaAutocomplete<T>(_ value: AriaAutocomplete) -> Attribute<T> {
  return .init("aria-autocomplete", value.rawValue)
}

public func ariaBusy<T>(_ value: Bool) -> Attribute<T> {
  return .init("aria-busy", String(value))
}

public func ariaChecked<T>(_ value: AriaToggled) -> Attribute<T> {
  return .init("aria-checked", value.rawValue)
}

public func ariaColcount<T>(_ value: Int) -> Attribute<T> {
  return .init("aria-colcount", String(value))
}

public func ariaColindex<T>(_ value: Int) -> Attribute<T> {
  return .init("aria-colindex", String(value))
}

public func ariaColspan<T>(_ value: Int) -> Attribute<T> {
  return .init("aria-colspan", String(value))
}

public func ariaControls<T>(_ value: Id) -> Attribute<T> {
  return .init("aria-controls", value)
}

public enum AriaCurrent: String {
  case date
  case `false`
  case location
  case page
  case step
  case time
  case `true`
}
extension AriaCurrent: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    if value {
      self = .true
    } else {
      self = .false
    }
  }
}
public func ariaCurrent<T>(_ value: AriaCurrent) -> Attribute<T> {
  return .init("aria-current", value.rawValue)
}

public func ariaDescribedby<T>(_ value: Id) -> Attribute<T> {
  return .init("aria-describedby", value)
}

public func ariaDetails<T>(_ value: Id) -> Attribute<T> {
  return .init("aria-details", value)
}

public func ariaDisabled<T>(_ value: Bool) -> Attribute<T> {
  return .init("aria-disabled", String(value))
}

public enum AriaDropeffect: String {
  case copy
  case execute
  case link
  case move
  case none
  case popup
}
public func ariaDropeffect<T>(_ value: AriaDropeffect) -> Attribute<T> {
  return .init("aria-dropeffect", value.rawValue)
}

public func ariaErrormessage<T>(_ value: Id) -> Attribute<T> {
  return .init("aria-errormessage", value)
}

public func ariaExpanded<T>(_ value: AriaBoolean) -> Attribute<T> {
  return .init("aria-expanded", value.rawValue)
}

public func ariaFlowto<T>(_ value: Id) -> Attribute<T> {
  return .init("aria-flowto", value)
}

public func ariaGrabbed<T>(_ value: AriaBoolean) -> Attribute<T> {
  return .init("aria-grabbed", value.rawValue)
}

public enum AriaHaspopup: String {
  case dialog
  case `false`
  case grid
  case menu
  case listbox
  case tree
}
extension AriaHaspopup: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    if value {
      self = .menu
    } else {
      self = .false
    }
  }
}
public func ariaHaspopup<T>(_ value: AriaHaspopup) -> Attribute<T> {
  return .init("aria-haspopup", value.rawValue)
}

public func ariaHidden<T>(_ value: AriaBoolean) -> Attribute<T> {
  return .init("aria-hidden", value.rawValue)
}

public enum AriaInvalid: String {
  case `false`
  case grammar
  case spelling
  case `true`
}
extension AriaInvalid: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    if value {
      self = .true
    } else {
      self = .false
    }
  }
}
public func ariaInvalid<T>(_ value: AriaInvalid) -> Attribute<T> {
  return .init("aria-invalid", value.rawValue)
}

public func ariaKeyshortcuts<T>(_ value: String) -> Attribute<T> {
  return .init("aria-keyshortcuts", value)
}

public func ariaLabel<T>(_ value: String) -> Attribute<T> {
  return .init("aria-label", value)
}

public func ariaLabelledby<T>(_ value: Id) -> Attribute<T> {
  return .init("aria-labelledby", value)
}

public func ariaLevel<T>(_ value: Int) -> Attribute<T> {
  return .init("aria-level", String(value))
}

public enum AriaLive: String {
  case assertive
  case off
  case polite
}
public func ariaLive<T>(_ value: AriaLive) -> Attribute<T> {
  return .init("aria-live", value.rawValue)
}

public func ariaModal<T>(_ value: Bool) -> Attribute<T> {
  return .init("aria-modal", String(value))
}

public func ariaMultiline<T>(_ value: Bool) -> Attribute<T> {
  return .init("aria-multiline", String(value))
}

public func ariaMultiselectable<T>(_ value: Bool) -> Attribute<T> {
  return .init("aria-multiselectable", String(value))
}

public enum AriaOrientation: String {
  case horizontal
  case undefined
  case vertical
}
public func ariaOrientation<T>(_ value: AriaOrientation) -> Attribute<T> {
  return .init("aria-orientation", value.rawValue)
}

public func ariaOwns<T>(_ value: Id) -> Attribute<T> {
  return .init("aria-owns", value)
}

public func ariaPlaceholder<T>(_ value: String) -> Attribute<T> {
  return .init("aria-placeholder", value)
}

public func ariaPosinset<T>(_ value: Int) -> Attribute<T> {
  return .init("aria-posinset", String(value))
}

public func ariaPressed<T>(_ value: AriaToggled) -> Attribute<T> {
  return .init("aria-pressed", value.rawValue)
}

public func ariaReadonly<T>(_ value: Bool) -> Attribute<T> {
  return .init("aria-readonly", String(value))
}

public enum AriaRelevant: String {
  case additions
  case all
  case removals
  case text
}
public func ariaRelevant<T>(_ value: [AriaRelevant]) -> Attribute<T> {
  return .init("aria-relevant", value.map(^\.rawValue).joined(separator: " "))
}

public func ariaRequired<T>(_ value: Bool) -> Attribute<T> {
  return .init("aria-required", String(value))
}

public func ariaRoledescription<T>(_ value: String) -> Attribute<T> {
  return .init("aria-roledescription", value)
}

public func ariaRowcount<T>(_ value: Int) -> Attribute<T> {
  return .init("aria-rowcount", String(value))
}

public func ariaRowindex<T>(_ value: Int) -> Attribute<T> {
  return .init("aria-rowindex", String(value))
}

public func ariaRowspan<T>(_ value: Int) -> Attribute<T> {
  return .init("aria-rowspan", String(value))
}

public func ariaSelected<T>(_ value: AriaBoolean) -> Attribute<T> {
  return .init("aria-selected", value.rawValue)
}

public func ariaSetsize<T>(_ value: Int) -> Attribute<T> {
  return .init("aria-setsize", String(value))
}

public enum AriaSort: String {
  case ascending
  case descending
  case none
  case other
}
public func ariaSort<T>(_ value: AriaSort) -> Attribute<T> {
  return .init("aria-sort", value.rawValue)
}

public func ariaValuemax<T>(_ value: Double) -> Attribute<T> {
  return .init("aria-valuemax", String(value))
}

public func ariaValuemin<T>(_ value: Double) -> Attribute<T> {
  return .init("aria-valuemin", String(value))
}

public func ariaValuenow<T>(_ value: Double) -> Attribute<T> {
  return .init("aria-valuenow", String(value))
}

public func ariaValuetext<T>(_ value: String) -> Attribute<T> {
  return .init("aria-valuetext", value)
}
