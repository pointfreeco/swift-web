import XCTest
import Prelude
import Css

class RenderTests: XCTestCase {

  func testRenderSelector_StandardCombinationOfElemIdClassPseudo() {
    let css = (a & .id("hello") & .`class`("world") & .pseudo(.firstChild)) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "a#hello.world:first-child{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_UsingStringLiterals() {
    let css = (a & "#hello" & ".world" & .pseudo(.firstChild)) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "a#hello.world:first-child{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Star() {
    let css = (body ** p ** .star) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body p *{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Elem() {
    let css = .elem(.footer) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "footer{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Id() {
    let css = .id("hello-world") % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "#hello-world{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Class() {
    let css = .`class`("hello-world") % (
      .background(Color.red)
    )

    XCTAssertEqual(
      ".hello-world{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_PseudoClass() {
    let css = (body ** p & .pseudo(.firstChild)) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body p:first-child{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_PseudoElem() {
    let css = (body ** p & .pseudoElem(.firstSentence)) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body p::first-sentence{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Attr() {
    let css = .attr(input, .match("type", .val, "button")) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "input[type=\"button\"]{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_AttributeBeginsOperator() {
    let css = input["type"^="button"] % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "input[type^=\"button\"]{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_AttributeContainsOperator() {
    let css = input["type"*="button"] % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "input[type*=\"button\"]{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_AttributeValOperator() {
    let css = input["type"=="button"] % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "input[type=\"button\"]{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_AttributeEndsOperator() {
    let css = input["type"¢="button"] % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "input[type$=\"button\"]{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_AttributeSpaceOperator() {
    let css = input["type"~="button"] % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "input[type~=\"button\"]{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_AttributeHyphenOperator() {
    let css = input["type"|="button"] % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "input[type|=\"button\"]{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Child() {
    let css = .child(body, p) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body > p{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_ChildOperator() {
    let css = (body > p) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body > p{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Deep() {
    let css = .deep(body, p) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body p{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_DeepOperator() {
    let css = (body ** p) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body p{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Adjacent() {
    let css = .adjacent(body, p) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body + p{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_AdjacentOperator() {
    let css = (body + p) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body + p{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Sibling() {
    let css = .sibling(p, a) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "p ~ a{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_SiblingOperator() {
    let css = (p ~ a) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "p ~ a{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Combined() {
    let css = .combined(p, .`class`("hello")) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "p.hello{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_CombinedOperator() {
    let css = (p & .`class`("hello")) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "p.hello{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_Union() {
    let css = .union(a, p) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "a, p{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_UnionOperator() {
    let css = (a | p) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "a, p{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderSelector_NestedCss() {
    let css = (body & .id("hello")) % (
      .background(Color.red)
        <> (p & .pseudo(.firstChild)) % (
          .background(Color.lime)
            <> (a & .`class`("blue")) % (
              .background(Color.blue)
          )
      )
    )

    XCTAssertEqual(
      "body#hello{background:#ff0000}body#hello p:first-child{background:#00ff00}body#hello p:first-child a.blue{background:#0000ff}",
      render(config: compact, css: css)
    )
  }

  func testNestedIds() {
    let css = .id("hello") % (
      .id("world") % (
        .background(Color.red)
      )
    )

    XCTAssertEqual(
      "#hello #world{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderAfterContent() {
    let css = (blockquote & .pseudoElem(.after)) % (
      .content(stringContent(""))
    )

    XCTAssertEqual(
      "blockquote::after{content:\"\"}",
      render(config: compact, css: css)
    )
  }

  func testMargins() {
    let css = span % (
      .margin(all: 0)
    )

    XCTAssertEqual(
      "span{margin-top:0;margin-right:0;margin-bottom:0;margin-left:0}",
      render(config: compact, css: css)
    )
  }

  func testFontInherit() {
    let css = (ol | ul) % (
      .listStyleType(.none)
    )

    XCTAssertEqual(
      "ol, ul{list-style-type:none}",
      render(config: compact, css: css)
    )
  }

  func testSubCss() {
    let css = body % (
      a % (
        .background(Color.red)
      )
    )

    XCTAssertEqual(
      "body a{background:#ff0000}",
      render(config: compact, css: css)
    )
  }

  func testRenderBoxSizing() {
    let css = body % (
      .boxSizing(.borderBox)
    )

    XCTAssertEqual(
      """

body {
  -webkit-box-sizing : border-box;
  -moz-box-sizing    : border-box;
  -ms-box-sizing     : border-box;
  -o-box-sizing      : border-box;
  box-sizing         : border-box;
}


""",
      render(config: pretty, css: css)
    )
  }

  func testASD() {
    let css = a % (
      .background(Color.red)
        <> .`class`("active") & (
          .background(Color.blue)
      )
    )

    XCTAssertEqual(
      "a{background:#ff0000}a.active{background:#0000ff}",
      render(config: compact, css: css)
    )
  }

  func testAllOperatorsTogether() {
    let css = (body & "#home" > ".link" | (".row" ** (".column" + ".column"))) % (
      .background(Color.red)
    )

    XCTAssertEqual(
      "body#home > .link, .row .column + .column{background:#ff0000}",
      render(config: compact, css: css)
    )
  }
}
