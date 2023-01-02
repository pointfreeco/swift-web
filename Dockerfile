FROM swift:5.7 as build

RUN apt-get update
RUN apt-get install -y libpq-dev libssl-dev libz-dev openssl

WORKDIR /package

COPY . ./
COPY .netrc /root/.netrc
RUN chmod 600 /root/.netrc

RUN rm -rf /package/.build/debug

RUN swift package resolve
RUN swift package clean
CMD swift test
