test-linux: 
	cp ~/.netrc ./.netrc
	docker build --tag swift-web-test . \
		&& docker run --rm swift-web-test
	rm ./.netrc

test-swift:
	swift test \
		--parallel

test-all: test-linux test-swift
