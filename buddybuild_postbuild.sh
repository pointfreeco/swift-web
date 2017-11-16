#!/usr/bin/env bash

xcodebuild test -scheme Prelude-Package -destination platform="macOS"
xcodebuild test -scheme Prelude-Package -destination platform="iOS Simulator,name=iPhone 8,OS=11.2"
