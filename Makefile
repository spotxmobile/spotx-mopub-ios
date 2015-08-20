#
# Copyright (c) 2015 spotxchange. All rights reserved.
#
SHELL = /bin/sh
BUILD_DIR = ./build

XCFLAGS=\
	-workspace MoPubIntegration.xcworkspace \
	-configuration Release \
	-derivedDataPath "$(BUILD_DIR)"

XCOPTS=\
	CODE_SIGN_IDENTITY="" \
	CODE_SIGNING_REQUIRED=NO

POD_OPTS=\
	--use-libraries\
	--allow-warnings

build: MoPubIntegration.xcworkspace
	mkdir -p $(BUILD_DIR)
	xcodebuild build $(XCFLAGS) -scheme MoPubIntegration -sdk iphoneos $(XCOPTS)
	xcodebuild build $(XCFLAGS) -scheme MoPubIntegration -sdk iphonesimulator $(XCOPTS)

MoPubIntegration.xcworkspace: Podfile
	pod install

lint:
	pod spec lint SpotX-MoPub-Plugin.podspec $(POD_OPTS)

deploy: clean build lint
	pod trunk push SpotX-MoPub-Plugin.podspec $(POD_OPTS)

clean:
	xcodebuild clean
	@rm -rf $(BUILD_DIR) $(DIST_DIR)

.phony: clean deploy lint build