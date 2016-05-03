#
# Copyright (c) 2016 SpotX. All rights reserved.
#
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

# Environment config file
#  -take a look at '.env.sample.rb' for a sample env file
ENV_FILE = './.env.rb'
require ENV_FILE if File.exists?(ENV_FILE)


def spotx_sdk
  if defined? SDK_PATH then
    pod 'SpotX-SDK-src', :path => SDK_PATH
  else
    pod 'SpotX-SDK', :git => 'https://github.com/spotxmobile/spotx-sdk-ios.git', :branch => 'master'
  end
end


def shared_pods
  pod 'mopub-ios-sdk'
  spotx_sdk
end


target 'MoPubIntegrationDemo' do
  shared_pods
  pod 'HockeySDK', '~> 3.8.5'
end

target 'MoPubIntegration' do
  shared_pods
end

target 'MoPubIntegrationTest' do
  shared_pods
end
