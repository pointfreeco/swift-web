import Prelude

public enum CssSelector {

  public enum Attribute {
    public enum Modifier {
      case begins
      case contains
      case ends
      case hyphen
      case space
      case val
    }

    case exists(String)
    case match(String, Modifier, String)
  }

  public enum PseudoElem {
    case after
    case before
    case firstLetter
    case firstSentence
    case selection
  }

  public enum PseudoClass {
    case active
    case checked
    case disabled
    case empty
    case enabled
    case firstChild
    case firstOfType
    case focus
    case hover
    case inRange
    case invalid
    case lang(String)
    case lastChild
    case lastOfType
    case link
    case nthChild(Int)
    case nthLastChild(Int)
    case nthLastOfType(Int)
    case nthOfType(Int)
    case onlyChild
    case onlyOfType
    case optional
    case outOfRange
    case readOnly
    case readWrite
    case required
    case root
    case target
    case valid
    case visited
    indirect case not(CssSelector)
  }

  public enum Element {
    case a
    case abbr
    case address
    case article
    case aside
    case audio
    case b
    case blockquote
    case body
    case canvas
    case caption
    case cite
    case code
    case dd
    case details
    case div
    case dl
    case dt
    case em
    case embed
    case fieldset
    case figcaption
    case figure
    case footer
    case form
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
    case header
    case hgroup
    case html
    case i
    case iframe
    case img
    case input
    case label
    case legend
    case li
    case menu
    case nav
    case ol
    case other(String)
    case p
    case pre
    case q
    case section
    case span
    case strong
    case summary
    case table
    case tbody
    case td
    case tfoot
    case th
    case thead
    case time
    case tr
    case u
    case ul
    case video
  }

  /// i.e.: *
  case star

  /// e.g.: body, a, span, div, ...
  case elem(Element)

  /// e.g.: #home, #nav, #sidebar, ...
  case id(String)

  /// e.g.: .active, .error, .item, ...
  case `class`(String)

  /// e.g.: :first-child, :active, :disabled, ...
  indirect case pseudo(PseudoClass)

  /// e.g.: ::before, ::after, ::first-letter, ...
  case pseudoElem(PseudoElem)

  /// e.g.: *[class^='col-'], input[type='submit'], ...
  indirect case attr(CssSelector, Attribute)

  /// i.e.: sel1 > sel2
  indirect case child(CssSelector, CssSelector)

  /// i.e.: sel1 ~ sel2
  indirect case sibling(CssSelector, CssSelector)

  /// i.e.: sel1 sel2
  indirect case deep(CssSelector, CssSelector)

  /// i.e. sel1 + sel2
  indirect case adjacent(CssSelector, CssSelector)

  /// e.g. input.active#email
  indirect case combined(CssSelector, CssSelector)

  /// e.g. sel1, sel2
  indirect case union(CssSelector, CssSelector)
}

extension CssSelector {
  public subscript(index: Attribute) -> CssSelector {
    return .attr(self, index)
  }
}

extension CssSelector {
  public subscript(index: String) -> CssSelector {
    return .attr(self, .exists(index))
  }
}

public func ^=(lhs: String, rhs: String) -> CssSelector.Attribute {
  return .match(lhs, .begins, rhs)
}
public func *=(lhs: String, rhs: String) -> CssSelector.Attribute {
  return .match(lhs, .contains, rhs)
}
public func ==(lhs: String, rhs: String) -> CssSelector.Attribute {
  return .match(lhs, .val, rhs)
}
infix operator ¢=
public func ¢=(lhs: String, rhs: String) -> CssSelector.Attribute {
  return .match(lhs, .ends, rhs)
}
public func ~=(lhs: String, rhs: String) -> CssSelector.Attribute {
  return .match(lhs, .space, rhs)
}
public func |=(lhs: String, rhs: String) -> CssSelector.Attribute {
  return .match(lhs, .hyphen, rhs)
}

extension CssSelector: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    switch value.first {
    case .some("#"):
      self = .id(String(value.dropFirst()))
    case .some("."):
      self = .`class`(String(value.dropFirst()))
    default:
      self = .elem(.other(value))
    }
  }
}

extension CssSelector: Semigroup {
  public static func <>(lhs: CssSelector, rhs: CssSelector) -> CssSelector {
    return .union(lhs, rhs)
  }
}

infix operator **: infixr6
public func ** (lhs: CssSelector, rhs: CssSelector) -> CssSelector {
  return .deep(lhs, rhs)
}

public func > (lhs: CssSelector, rhs: CssSelector) -> CssSelector {
  return .child(lhs, rhs)
}

public func + (lhs: CssSelector, rhs: CssSelector) -> CssSelector {
  return .adjacent(lhs, rhs)
}

public func | (lhs: CssSelector, rhs: CssSelector) -> CssSelector {
  return .union(lhs, rhs)
}

public func & (lhs: CssSelector, rhs: CssSelector) -> CssSelector {
  return .combined(lhs, rhs)
}

infix operator ~: infixr6
public func ~ (lhs: CssSelector, rhs: CssSelector) -> CssSelector {
  return .sibling(lhs, rhs)
}

extension CssSelector {
  public var idString: String? {
    switch self {
    case .star, .elem, .class, .pseudo, .pseudoElem, .attr, .child, .sibling, .deep, .adjacent, .combined,
         .union:
      return nil
    case let .id(id):
      return id
    }
  }
}
