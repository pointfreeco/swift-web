imports = \
	@testable import ApplicativeRouterTests; \
	@testable import ApplicativeRouterHttpPipelineSupport; \
	@testable import CssTests; \
	@testable import CssResetTests; \
	@testable import HtmlTests; \
	@testable import HtmlCssSupportTests; \
	@testable import HtmlPrettyPrintTests; \
	@testable import HtmlTestSupportTests; \
	@testable import HttpPipelineTests; \
	@testable import HttpPipelineHtmlSupportTests; \
	@testable import HttpPipelineTestSupportTests; \
	@testable import MediaTypeTests;

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
