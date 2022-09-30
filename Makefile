test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.6 \
		bash -c 'apt-get update && apt-get -y install libssl-dev libz-dev make openssl && make test-swift'

test-swift:
	swift test \
		--parallel

test-all: test-linux test-swift
