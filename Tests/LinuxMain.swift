// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest

@testable import ApplicativeRouterHttpPipelineSupportTests; @testable import ApplicativeRouterTests; @testable import CssTests; @testable import CssResetTests; @testable import HtmlCssSupportTests; @testable import HtmlPlainTextPrintTests; @testable import HttpPipelineTests; @testable import HttpPipelineHtmlSupportTests; @testable import UrlFormEncodingTests;
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
    ("testAllOperatorsTogether", testAllOperatorsTogether),
    ("testClipRect", testClipRect)
  ]
}
extension EncryptionTests {
  static var allTests: [(String, (EncryptionTests) -> () throws -> Void)] = [
    ("testEncrypt", testEncrypt),
    ("testDecrypt", testDecrypt),
    ("testDigest", testDigest)
  ]
}
extension FlexBoxTests {
  static var allTests: [(String, (FlexBoxTests) -> () throws -> Void)] = [
    ("testFlexBox", testFlexBox)
  ]
}
extension FullStylesheetTests {
  static var allTests: [(String, (FullStylesheetTests) -> () throws -> Void)] = [
    ("testABigStyleSheet", testABigStyleSheet)
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
    ("testRedirectUnrelatedHosts", testRedirectUnrelatedHosts),
    ("testRequireHerokuHttps", testRequireHerokuHttps),
    ("testRequireHttps", testRequireHttps),
    ("testRequestLogger", testRequestLogger),
    ("testBasicAuthValidationIsCaseInsensitive", testBasicAuthValidationIsCaseInsensitive)
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
    ("testSimpleQueryParams_SomeMissing", testSimpleQueryParams_SomeMissing),
    ("testCodableFormDataPostBody", testCodableFormDataPostBody),
    ("testRedirect", testRedirect)
  ]
}
extension UrlFormDecoderTests {
  static var allTests: [(String, (UrlFormDecoderTests) -> () throws -> Void)] = [
    ("testOptionality", testOptionality),
    ("testPlusses", testPlusses),
    ("testDefaultStrategyAccumulatePairs", testDefaultStrategyAccumulatePairs),
    ("testBrackets", testBrackets),
    ("testBracketsWithIndices", testBracketsWithIndices),
    ("testDataDecodingWithBase64", testDataDecodingWithBase64),
    ("testDateDecodingWithSecondsSince1970", testDateDecodingWithSecondsSince1970),
    ("testDateDecodingWithMillisecondsSince1970", testDateDecodingWithMillisecondsSince1970),
    ("testDateDecodingWithIso8601", testDateDecodingWithIso8601),
    ("testBools", testBools)
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

// swiftlint:disable trailing_comma
XCTMain([
  testCase(ApplicativeRouterHttpPipelineSupportTests.allTests),
  testCase(BackgroundTests.allTests),
  testCase(BorderTests.allTests),
  testCase(CssRenderTests.allTests),
  testCase(EncryptionTests.allTests),
  testCase(FlexBoxTests.allTests),
  testCase(FullStylesheetTests.allTests),
  testCase(HttpPipelineHtmlSupportTests.allTests),
  testCase(HttpPipelineTests.allTests),
  testCase(MediaTests.allTests),
  testCase(PlainTextTests.allTests),
  testCase(PropertyTests.allTests),
  testCase(ResetTests.allTests),
  testCase(SharedMiddlewareTransformersTests.allTests),
  testCase(SignedCookieTests.allTests),
  testCase(SizeTests.allTests),
  testCase(SupportTests.allTests),
  testCase(SyntaxRouterTests.allTests),
  testCase(UrlFormDecoderTests.allTests),
  testCase(UrlFormEncoderTests.allTests),
])
// swiftlint:enable trailing_comma
