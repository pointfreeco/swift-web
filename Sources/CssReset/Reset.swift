import Css
import Prelude

private let allReset: Stylesheet = (
  a
    | abbr
    | acronym
    | address
    | article
    | aside
    | audio
    | b
    | blockquote
    | body
    | canvas
    | caption
    | cite
    | code
    | dd
    | details
    | div
    | dl
    | dt
    | em
    | embed
    | fieldset
    | figure
    | figcaption
    | footer
    | form
    | h1
    | h2
    | h3
    | h4
    | h5
    | h6
    | header
    | hgroup
    | html
    | iframe
    | i
    | img
    | input
    | label
    | legend
    | li
    | menu
    | nav
    | ol
    | section
    | span
    | strong
    | summary
    | table
    | tbody
    | td
    | tfoot
    | th
    | thead
    | time
    | tr
    | p
    | pre
    | q
    | u
    | ul
    | video
  ) % (
    margin(all: 0)
      <> padding(all: 0)
      <> fontSize(pct(100))
      <> fontFamily(.inherit)
      <> fontStyle(.inherit)
      <> fontWeight(.inherit)
      <> verticalAlign(.baseline)
)

private let blockResets = (
  article
    | footer
    | header
    | menu
    | nav
    | section
  ) % (
    display(block)
)

private let bodyReset: Stylesheet
  = body % (
    lineHeight(1)
)

private let quoteReset: Stylesheet
  = (

    blockquote & .pseudoElem(.after)
      | blockquote & .pseudoElem(.before)
      | q & .pseudoElem(.before)
      | q & .pseudoElem(.after)

    ) % (
      content(stringContent(""))
        <> content(.none)
    )
    <>
    (blockquote | q) % (
      quotes(.none)
)

private let listReset = (ol | ul) % (
  listStyleType(.none)
)

private let tableResets =
  table % (
    borderCollapse(collapse)
      <> borderSpacing(0)
)

public let reset: Stylesheet =
  allReset
    <> blockResets
    <> bodyReset
    <> listReset
    <> quoteReset
    <> tableResets

