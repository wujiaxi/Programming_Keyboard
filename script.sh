#!/bin/bash
set -e

sudo gem install xcpretty

OS=${1:-'10.1'}

echo $OS

echo "building the project"
xcodebuild \
	-project Programming_Keyboard.xcodeproj \
	-scheme Programming_Keyboard \
	-sdk iphonesimulator$OS 'CODE_SIGN_IDENTITY=-' \
	-destination "platform=iOS Simulator,name=iPad Air 2,OS=$OS" \
	test|xcpretty

