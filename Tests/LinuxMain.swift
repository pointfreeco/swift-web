// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest

@testable import ApplicativeRouterHttpPipelineSupportTests; @testable import ApplicativeRouterTests; @testable import CssTests; @testable import CssResetTests; @testable import HtmlTests; @testable import HtmlCssSupportTests; @testable import HtmlPrettyPrintTests; @testable import HttpPipelineTests; @testable import HttpPipelineHtmlSupportTests; @testable import UrlFormEncodingTests;
extension ApplicativeRouterHttpPipelineSupportTests {
  static var allTests: [(String, (ApplicativeRouterHttpPipelineSupportTests) -> () throws -> Void)] = [
    ("testRoute", testRoute),
    ("testRoute_UnrecognizedWithCustomNotFound", testRoute_UnrecognizedWithCustomNotFound)
  ]
}
extension BackgroundTests {
  static var allTests: [(String, (BackgroundTests) -> () throws -> Void)] = [
    ("testBackground_RGBA", testBackground_RGBA)
  ]
}
extension BorderTests {
  static var allTests: [(String, (BorderTests) -> () throws -> Void)] = [
    ("testBorders", testBorders)
  ]
}
extension CssRenderTests {
  static var allTests: [(String, (CssRenderTests) -> () throws -> Void)] = [
    ("testRenderSelector_StandardCombinationOfElemIdClassPseudo", testRenderSelector_StandardCombinationOfElemIdClassPseudo),
    ("testRenderSelector_UsingStringLiterals", testRenderSelector_UsingStringLiterals),
    ("testRenderSelector_Star", testRenderSelector_Star),
    ("testRenderSelector_Elem", testRenderSelector_Elem),
    ("testRenderSelector_Id", testRenderSelector_Id),
    ("testRenderSelector_Class", testRenderSelector_Class),
    ("testRenderSelector_PseudoClass", testRenderSelector_PseudoClass),
    ("testRenderSelector_PseudoElem", testRenderSelector_PseudoElem),
    ("testRenderSelector_Attr", testRenderSelector_Attr),
    ("testRenderSelector_AttributeBeginsOperator", testRenderSelector_AttributeBeginsOperator),
    ("testRenderSelector_AttributeContainsOperator", testRenderSelector_AttributeContainsOperator),
    ("testRenderSelector_AttributeValOperator", testRenderSelector_AttributeValOperator),
    ("testRenderSelector_AttributeEndsOperator", testRenderSelector_AttributeEndsOperator),
    ("testRenderSelector_AttributeSpaceOperator", testRenderSelector_AttributeSpaceOperator),
    ("testRenderSelector_AttributeHyphenOperator", testRenderSelector_AttributeHyphenOperator),
    ("testRenderSelector_Child", testRenderSelector_Child),
    ("testRenderSelector_ChildOperator", testRenderSelector_ChildOperator),
    ("testRenderSelector_Deep", testRenderSelector_Deep),
    ("testRenderSelector_DeepOperator", testRenderSelector_DeepOperator),
    ("testRenderSelector_Adjacent", testRenderSelector_Adjacent),
    ("testRenderSelector_AdjacentOperator", testRenderSelector_AdjacentOperator),
    ("testRenderSelector_Sibling", testRenderSelector_Sibling),
    ("testRenderSelector_SiblingOperator", testRenderSelector_SiblingOperator),
    ("testRenderSelector_Combined", testRenderSelector_Combined),
    ("testRenderSelector_CombinedOperator", testRenderSelector_CombinedOperator),
    ("testRenderSelector_Union", testRenderSelector_Union),
    ("testRenderSelector_UnionOperator", testRenderSelector_UnionOperator),
    ("testRenderSelector_NestedCss", testRenderSelector_NestedCss),
    ("testNestedIds", testNestedIds),
    ("testRenderAfterContent", testRenderAfterContent),
    ("testMargins", testMargins),
    ("testFontInherit", testFontInherit),
    ("testSubCss", testSubCss),
    ("testRenderBoxSizing", testRenderBoxSizing),
    ("testASD", testASD),
    ("testAllOperatorsTogether", testAllOperatorsTogether)
  ]
}
extension EncodedStringTests {
  static var allTests: [(String, (EncodedStringTests) -> () throws -> Void)] = [
    ("testEscape", testEscape),
    ("testDoesntEscapeInStyleTag", testDoesntEscapeInStyleTag),
    ("testDoesntEscapeInScript", testDoesntEscapeInScript),
    ("testEscapesAttributeValues", testEscapesAttributeValues)
  ]
}
extension FlexBoxTests {
  static var allTests: [(String, (FlexBoxTests) -> () throws -> Void)] = [
    ("testFlexBox", testFlexBox)
  ]
}
extension FullDocumentTests {
  static var allTests: [(String, (FullDocumentTests) -> () throws -> Void)] = [
    ("testDocument", testDocument)
  ]
}
extension FullStylesheetTests {
  static var allTests: [(String, (FullStylesheetTests) -> () throws -> Void)] = [
    ("testABigStyleSheet", testABigStyleSheet)
  ]
}
extension HTMLTests {
  static var allTests: [(String, (HTMLTests) -> () throws -> Void)] = [
    ("testImgTag", testImgTag),
    ("testHtml3", testHtml3),
    ("testHtmlTag", testHtmlTag),
    ("testATag", testATag),
    ("testHtmlWithInlineStyles", testHtmlWithInlineStyles),
    ("testHtmlInput", testHtmlInput),
    ("testScriptTag", testScriptTag),
    ("testPrettyRender", testPrettyRender),
    ("testDocument", testDocument),
    ("testTables", testTables)
  ]
}
extension HtmlRenderTests {
  static var allTests: [(String, (HtmlRenderTests) -> () throws -> Void)] = [
  ]
}
extension HttpPipelineHtmlSupportTests {
  static var allTests: [(String, (HttpPipelineHtmlSupportTests) -> () throws -> Void)] = [
    ("testResponse", testResponse)
  ]
}
extension HttpPipelineTests {
  static var allTests: [(String, (HttpPipelineTests) -> () throws -> Void)] = [
    ("testPipeline", testPipeline),
    ("testHtmlResponse", testHtmlResponse),
    ("testRedirect", testRedirect),
    ("testRedirect_AdditionalHeaders", testRedirect_AdditionalHeaders),
    ("testWriteHeaders", testWriteHeaders),
    ("testCookies", testCookies),
    ("testCookieOptions", testCookieOptions)
  ]
}
extension MediaTests {
  static var allTests: [(String, (MediaTests) -> () throws -> Void)] = [
    ("testMediaQueryOnly", testMediaQueryOnly),
    ("testMediaQueryNot", testMediaQueryNot)
  ]
}
extension PlainTextTests {
  static var allTests: [(String, (PlainTextTests) -> () throws -> Void)] = [
    ("testPlainText", testPlainText)
  ]
}
extension PrettyTests {
  static var allTests: [(String, (PrettyTests) -> () throws -> Void)] = [
    ("testPretty", testPretty)
  ]
}
extension PropertyTests {
  static var allTests: [(String, (PropertyTests) -> () throws -> Void)] = [
    ("testPrefixed_Monoid", testPrefixed_Monoid)
  ]
}
extension ResetTests {
  static var allTests: [(String, (ResetTests) -> () throws -> Void)] = [
    ("testResetPretty", testResetPretty),
    ("testResetCompact", testResetCompact)
  ]
}
extension SharedMiddlewareTransformersTests {
  static var allTests: [(String, (SharedMiddlewareTransformersTests) -> () throws -> Void)] = [
    ("testBasicAuth_Unauthorized", testBasicAuth_Unauthorized),
    ("testBasicAuth_Unauthorized_ProtectedPredicate", testBasicAuth_Unauthorized_ProtectedPredicate),
    ("testBasicAuth_Unauthorized_Realm", testBasicAuth_Unauthorized_Realm),
    ("testBasicAuth_Unauthorized_CustomFailure", testBasicAuth_Unauthorized_CustomFailure),
    ("testBasicAuth_Authorized", testBasicAuth_Authorized),
    ("testContentLengthMiddlewareTransformer", testContentLengthMiddlewareTransformer),
    ("testRedirectUnrelatedHosts", testRedirectUnrelatedHosts),
    ("testRequireHerokuHttps", testRequireHerokuHttps),
    ("testRequireHttps", testRequireHttps),
    ("testRequestLogger", testRequestLogger)
  ]
}
extension SignedCookieTests {
  static var allTests: [(String, (SignedCookieTests) -> () throws -> Void)] = [
    ("testSignedCookie", testSignedCookie),
    ("testSignedCookie_EncodableValue", testSignedCookie_EncodableValue),
    ("testEncryptedCookie", testEncryptedCookie),
    ("testEncryptedCookie_EncodableValue", testEncryptedCookie_EncodableValue)
  ]
}
extension SizeTests {
  static var allTests: [(String, (SizeTests) -> () throws -> Void)] = [
    ("testCalc", testCalc)
  ]
}
extension SupportTests {
  static var allTests: [(String, (SupportTests) -> () throws -> Void)] = [
    ("testStyleAttribute", testStyleAttribute),
    ("testStyleElement", testStyleElement)
  ]
}
extension SyntaxRouterTests {
  static var allTests: [(String, (SyntaxRouterTests) -> () throws -> Void)] = [
    ("testHome", testHome),
    ("testRoot", testRoot),
    ("testRequest_WithBaseUrl", testRequest_WithBaseUrl),
    ("testAbsoluteString", testAbsoluteString),
    ("testLitFails", testLitFails),
    ("testPathComponents_IntParam", testPathComponents_IntParam),
    ("testPathComponents_StringParam", testPathComponents_StringParam),
    ("testPostBodyField", testPostBodyField),
    ("testPostBodyJsonDecodable", testPostBodyJsonDecodable),
    ("testSimpleQueryParams", testSimpleQueryParams),
    ("testSimpleQueryParams_SomeMissing", testSimpleQueryParams_SomeMissing)
  ]
}
extension UrlFormEncoderTests {
  static var allTests: [(String, (UrlFormEncoderTests) -> () throws -> Void)] = [
    ("testEncoding_DeepObject", testEncoding_DeepObject),
    ("testEncoding_Emtpy", testEncoding_Emtpy),
    ("testEncoding_RootArray_SimpleObjects", testEncoding_RootArray_SimpleObjects),
    ("testEncoding_DoubleArray", testEncoding_DoubleArray),
    ("testEncodingCodable", testEncodingCodable)
  ]
}
extension ViewTests {
  static var allTests: [(String, (ViewTests) -> () throws -> Void)] = [
    ("testSemigroupAssociativity", testSemigroupAssociativity),
    ("testSemigroup", testSemigroup),
    ("testProfunctor", testProfunctor)
  ]
}

// swiftlint:disable trailing_comma
XCTMain([
  testCase(ApplicativeRouterHttpPipelineSupportTests.allTests),
  testCase(BackgroundTests.allTests),
  testCase(BorderTests.allTests),
  testCase(CssRenderTests.allTests),
  testCase(EncodedStringTests.allTests),
  testCase(FlexBoxTests.allTests),
  testCase(FullDocumentTests.allTests),
  testCase(FullStylesheetTests.allTests),
  testCase(HTMLTests.allTests),
  testCase(HtmlRenderTests.allTests),
  testCase(HttpPipelineHtmlSupportTests.allTests),
  testCase(HttpPipelineTests.allTests),
  testCase(MediaTests.allTests),
  testCase(PlainTextTests.allTests),
  testCase(PrettyTests.allTests),
  testCase(PropertyTests.allTests),
  testCase(ResetTests.allTests),
  testCase(SharedMiddlewareTransformersTests.allTests),
  testCase(SignedCookieTests.allTests),
  testCase(SizeTests.allTests),
  testCase(SupportTests.allTests),
  testCase(SyntaxRouterTests.allTests),
  testCase(UrlFormEncoderTests.allTests),
  testCase(ViewTests.allTests),
])
// swiftlint:enable trailing_comma
