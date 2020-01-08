FROM swift:5.1

# RUN apt-get update
# RUN apt-get install -y openssl libssl-dev
RUN apt-get update
RUN apt-get install -y libssl-dev libz-dev openssl

WORKDIR /package

COPY . ./

# Helps with: https://bugs.swift.org/browse/SR-6500
RUN rm -rf /package/.build/debug

RUN swift package resolve
RUN swift package clean
CMD swift test --enable-pubgrub-resolver --parallel
