xcodeproj:
	xcrun --toolchain swift swift package generate-xcodeproj

test-linux: linux-main
	docker run \
		-it \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.1 \
		bash -c 'apt-get update && apt-get -y install openssl libssl-dev libz-dev && swift test --enable-pubgrub-resolver --enable-test-discovery --parallel'

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
		-destination platform="iOS Simulator,name=iPhone 11 Pro Max,OS=13.2.2" \
		| xcpretty

test-swift:
	swift test

test-all: test-linux test-mac test-ios test-swift
