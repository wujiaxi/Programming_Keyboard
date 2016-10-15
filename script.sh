#!/bin/bash
set -e

echo "building the project"
xcodebuild -project Programming_Keyboard.xcodeproj -target unittests build
xcodebuild -project Programming_Keyboard.xcodeproj -target Programming_Keyboard build

echo "running unit tests"
xcodebuild test -project Programming_Keyboard.xcodeproj -scheme unittests

