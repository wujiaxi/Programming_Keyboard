#!/bin/bash
set -e
echo "running unit tests"
xctool -project Programming_Keyboard.xcodeproj -scheme unittests run-tests

echo "building the project"
xctool -project Programming_Keyboard.xcodeproj -scheme Programming_Keyboard -sdk iphonesimulator10.0 

