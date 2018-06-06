# Copyright (c) 2018 spotxchange. All rights reserved.
#
# Be sure to run `pod spec lint' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.version          = '4.0.1'
  s.name             = 'SpotX-MoPub-Plugin'
  s.summary          = 'MoPub plugin for SpotXchange'
  s.authors          = 'SpotXchange, Inc.'
  s.homepage         = 'http://www.spotxchange.com'
  s.source           = { :git => 'https://github.com/spotxmobile/spotx-mopub-ios.git', tag: '4.0.1' }
  s.license          =  'MIT'
  s.platform         = :ios, '9.0'
  s.requires_arc     = true

  s.source_files  = 'Classes/*.{h,m}'

  s.dependency 'mopub-ios-sdk', '~> 4.3'
  s.dependency 'SpotX-SDK'
end
