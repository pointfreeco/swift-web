test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.3 \
		bash -c 'apt-get update && apt-get -y install openssl libssl-dev libz-dev && make test-swift'

test-swift:
	swift test \
		--enable-test-discovery \
		--parallel

test-all: test-linux test-swift
