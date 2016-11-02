#!/bin/bash
set -x
OS=${1:-'10.1'}

sudo gem install xcpretty
sudo gem install cocoapods


pod install --verbose

build_errors_file=build_errors.log

# Pipe errors to file
echo "building the project"
xcodebuild -workspace Programming_Keyboard.xcworkspace \
	-scheme Programming_Keyboard \
	-sdk iphonesimulator$OS 'CODE_SIGN_IDENTITY=-' \
	-destination "platform=iOS Simulator,name=iPad Air 2,OS=$OS" \
	test|xcpretty 2> $build_errors_file

errors=`grep -wc "The following build commands failed" $build_errors_file`
if [ "$errors" != "0" ]
then
    echo "BUILD FAILED. Error Log:"
    cat $build_errors_file
    rm $build_errors_file
    exit 1
fi
rm $build_errors_file
