//
//  Copyright (c) 2015 SpotXchange, Inc. All rights reserved.
//

#import "SpotXInterstitial.h"
#import "SpotXAdManager.h"

NSString *const kSpotXIABCategoryKey = @"IAB_category";
NSString *const kSpotXAppStoreURLKey = @"appstore_url";
NSString *const kSpotXPlayStoreURLKey = @"playstore_url";
NSString *const kSpotXChannelIDKey = @"channel_id";
NSString *const kSpotXAppDomainKey = @"app_domain";
NSString *const kSpotXPrefetchKey = @"prefetch";
NSString *const kSpotxAutoInitKey = @"auto_init";
NSString *const kSpotXInAppBrowserKey = @"in_app_browser";

@interface SpotXInterstitial () <SpotXAdViewDelegate>
@end

@implementation SpotXInterstitial {
  NSString *_adId;
  NSDictionary *_info;
  SpotXAdView *_adView;
  UIViewController *_viewController;
}


#pragma mark - MoPub Hooks

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
  NSString *channelId = info[kSpotXChannelIDKey];
  NSString *domain = info[kSpotXAppDomainKey];

  if (!(channelId.length & domain.length)) {
    [NSException raise:NSInvalidArgumentException
                format:@"%@ and %@ are required", kSpotXChannelIDKey, kSpotXAppDomainKey];
  }

  _info = info;

  NSDictionary *settings = [self adViewSettingsWithInfo:info defaults:self.defaultAdViewSettings];

  _adView = [[SpotXAdView alloc] initForChannelId:channelId
                                        andDomain:domain
                                   withProperties:settings
                                      andDelegate:self];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
  _viewController = rootViewController;
  [self.delegate interstitialCustomEventWillAppear:self];
  [self.delegate interstitialCustomEventDidAppear:self];
}


#pragma mark - SpotX AdView Settings

/**
 * Generates a GUID MoPub can use for tracking this instance.
 */
- (NSString *)adId
{
  if (!_adId) {
    _adId = [[NSProcessInfo processInfo] globallyUniqueString];
  }
  return _adId;
}

- (NSDictionary *)defaultAdViewSettings
{
  return @{
     SpotXAdViewPreFetchKey: @NO,
     SpotXAdViewAutoInitKey: @NO,
     SpotXAdViewUseInAppBrowserKey: @NO
  };
}

- (NSDictionary *)adViewSettingsWithInfo:(NSDictionary *)info defaults:(NSDictionary *)defaults {
  NSMutableDictionary *settings = [defaults mutableCopy];

  NSArray *keys = @[
    kSpotXIABCategoryKey, kSpotXAppStoreURLKey, kSpotXPrefetchKey,
    kSpotxAutoInitKey, kSpotXInAppBrowserKey
  ];

  for (NSString *key in keys) {
    id value = info[key];
    if (value) {
      settings[key] = value;
    }
  }

  return settings;
}


#pragma mark - SpotXAdViewDelegate


- (void)adError:(SpotXAdView *)adView
{
  NSError *error = [NSError errorWithDomain:@"spotx-mopub-ios" code:0 userInfo:_info];
  [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adLoaded:(SpotXAdView *)adView
{
  [self.delegate interstitialCustomEvent:self didLoadAd:self.adId];
  [self.delegate interstitialCustomEventWillAppear:self];
  [_adView startAd];
}

- (void)adStarted:(SpotXAdView *)adView
{
  [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)adCompleted:(SpotXAdView *)adView
{
  [self.delegate interstitialCustomEventWillDisappear:self];
  [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
