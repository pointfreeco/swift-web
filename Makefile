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

xcodeproj:
	swift package generate-xcodeproj

linux-main:
	sourcery \
		--sources ./Tests/ \
		--templates ./.sourcery-templates/ \
		--output ./Tests/ \
		--args testimports='$(imports)' \
		&& mv ./Tests/LinuxMain.generated.swift ./Tests/LinuxMain.swift

test-linux: linux-main
	docker build --tag swift-web-test . \
		&& docker run --rm swift-web-test

test-macos: xcodeproj
	set -o pipefail && \
	xcodebuild test \
		-scheme Web-Package \
		-destination platform="macOS" \
		| xcpretty

test-ios: xcodeproj
	set -o pipefail && \
	xcodebuild test \
		-scheme Web-Package \
		-destination platform="iOS Simulator,name=iPhone 8,OS=11.0" \
		| xcpretty

test-swift:
	swift test

test-all: test-linux test-mac test-ios
