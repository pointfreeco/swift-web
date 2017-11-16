imports = \
	@testable import ApplicativeRouterHttpPipelineSupportTests; \
	@testable import ApplicativeRouterTests; \
	@testable import CssTests; \
	@testable import CssResetTests; \
	@testable import HtmlTests; \
	@testable import HtmlCssSupportTests; \
	@testable import HtmlPrettyPrintTests; \
	@testable import HttpPipelineTests; \
	@testable import HttpPipelineHtmlSupportTests;

linux-main:
	sourcery \
		--sources ./Tests/ \
		--templates ./.sourcery-templates/ \
		--output ./Tests/ \
		--args testimports='$(imports)' \
		&& mv ./Tests/LinuxMain.generated.swift ./Tests/LinuxMain.swift

test: linux-main
	swift test

test-linux: linux-main
	docker build --tag swift-web-test . \
		&& docker run --rm swift-web-test
