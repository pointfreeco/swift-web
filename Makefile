imports = \
	@testable import ApplicativeRouterHttpPipelineSupportTests; \
	@testable import ApplicativeRouterTests; \
	@testable import CssTests; \
	@testable import CssResetTests; \
	@testable import HtmlCssSupportTests; \
	@testable import HtmlPlainTextPrintTests; \
	@testable import HttpPipelineTests; \
	@testable import HttpPipelineHtmlSupportTests; \
	@testable import UrlFormEncodingTests;

xcodeproj:
	xcrun --toolchain swift swift package generate-xcodeproj --xcconfig-overrides Development.xcconfig
	xed .

bootstrap: common-crypto-mm xcodeproj xcodeproj-mm

common-crypto-mm:
	-@sudo mkdir -p "$(COMMON_CRYPTO_PATH)"
	-@echo "$$COMMON_CRYPTO_MODULE_MAP" | sudo tee "$(COMMON_CRYPTO_MODULE_MAP_PATH)" > /dev/null

xcodeproj-mm:
	-@ls Web.xcodeproj/GeneratedModuleMap | xargs -n1 -I '{}' sudo mkdir -p "$(FRAMEWORKS_PATH)/{}.framework"
	-@ls Web.xcodeproj/GeneratedModuleMap | xargs -n1 -I '{}' sudo cp "./Web.xcodeproj/GeneratedModuleMap/{}/module.modulemap" "$(FRAMEWORKS_PATH)/{}.framework/module.map"

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
		-destination platform="iOS Simulator,name=iPhone XR,OS=13.0" \
		| xcpretty

test-swift:
	swift test

test-all: test-linux test-mac test-ios

SDK_PATH = $(shell xcrun --show-sdk-path)
FRAMEWORKS_PATH = $(SDK_PATH)/System/Library/Frameworks
COMMON_CRYPTO_PATH = $(FRAMEWORKS_PATH)/CommonCrypto.framework
COMMON_CRYPTO_MODULE_MAP_PATH = $(COMMON_CRYPTO_PATH)/module.map
define COMMON_CRYPTO_MODULE_MAP
module CommonCrypto [system] {
  header "$(SDK_PATH)/usr/include/CommonCrypto/CommonCrypto.h"
  header "$(SDK_PATH)/usr/include/CommonCrypto/CommonRandom.h"
  export *
}
endef
export COMMON_CRYPTO_MODULE_MAP
