import XCTest

import ApplicativeRouterHttpPipelineSupportTests
import ApplicativeRouterTests
import CssResetTests
import CssTests
import HtmlCssSupportTests
import HtmlPlainTextPrintTests
import HttpPipelineHtmlSupportTests
import HttpPipelineTests
import UrlFormEncodingTests

var tests = [XCTestCaseEntry]()
tests += ApplicativeRouterHttpPipelineSupportTests.__allTests()
tests += ApplicativeRouterTests.__allTests()
tests += CssResetTests.__allTests()
tests += CssTests.__allTests()
tests += HtmlCssSupportTests.__allTests()
tests += HtmlPlainTextPrintTests.__allTests()
tests += HttpPipelineHtmlSupportTests.__allTests()
tests += HttpPipelineTests.__allTests()
tests += UrlFormEncodingTests.__allTests()

XCTMain(tests)
