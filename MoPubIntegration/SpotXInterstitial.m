//
//  Copyright (c) 2015 SpotXchange, Inc. All rights reserved.
//

#import "SpotXInterstitial.h"
#import "SpotX.h"


@interface SpotXInterstitial () <SpotXAdDelegate>
@end

@implementation SpotXInterstitial {
  NSString *_adId;
  NSDictionary *_info;
  SpotXView *_adView;
  UIViewController *_viewController;
  dispatch_once_t _clickOnce;
}


#pragma mark - MoPub Hooks

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
  NSError *error = nil;
  if (![self validateCustomEventInfo:info error:&error]) {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    return;
  }

  _adId = [[NSProcessInfo processInfo] globallyUniqueString];
  _info = info;

  NSString *category = info[@"iab_category"];
  NSString *section = info[@"iab_section"];
  NSString *url = info[@"appstore_url"];
  NSString *domain = info[@"app_domain"];
  NSString *channelID = info[@"channel_id"];

  // Initialize SpotX SDK exactly once
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [SpotX initializeWithApiKey:nil category:category section:section url:url];
  });

  _adView = [[SpotXView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _adView.delegate = self;

  _adView.channelID = channelID;
  _adView.params = info[@"params"];

  id settings = _adView.settings;
  [self applySettings:settings value:info[@"use_https"] forKey:@"useHTTPS"];
  [self applySettings:settings value:info[@"use_native_browser"] forKey:@"useNativeBrowser"];
  [self applySettings:settings value:info[@"allow_calendar"] forKey:@"allowCalendar"];
  [self applySettings:settings value:info[@"allow_phone"] forKey:@"allowPhone"];
  [self applySettings:settings value:info[@"allow_sms"] forKey:@"allowSMS"];
  [self applySettings:settings value:info[@"allow_storage"] forKey:@"allowStorage"];
  [self applySettings:settings value:info[@"autoplay"] forKey:@"autoplay"];
  [self applySettings:settings value:info[@"skippable"] forKey:@"skippable"];
  [self applySettings:settings value:info[@"trackable"] forKey:@"trackable"];

  [_adView startLoading];
  [_adView show];

  [self.delegate interstitialCustomEventWillAppear:self];
  [self.delegate interstitialCustomEventDidAppear:self];
}

- (BOOL)validateCustomEventInfo:(NSDictionary *)info error:(NSError **)error
{
  NSArray *required = @[ @"channel_id", @"iab_category", @"iab_section",
                         @"appstore_url", @"app_url" ];

  for (NSString *key in required) {
    id value = info[key];
    if (value == nil) {
      if (error) {
        NSString *msg = [NSString stringWithFormat:@"%@ is not defined", key];
        *error = [NSError errorWithDomain:@"spotx-mopub-ios" code:0 userInfo:@{NSLocalizedDescriptionKey:msg}];
      }
      return NO;
    }
  }

  return YES;
}

- (void)applySettings:(id)settings value:(id)value forKey:(NSString *)key
{
  if (value != nil) {
    [settings setValue:value forKey:key];
  }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
  _viewController = rootViewController;
  [_adView show];
  [self.delegate interstitialCustomEventWillAppear:self];
  [self.delegate interstitialCustomEventDidAppear:self];
}


#pragma mark - SpotXAdDelegate

- (void)presentViewController:(UIViewController *)viewControllerToPresent
{
  [_viewController presentViewController:viewControllerToPresent animated:YES completion:nil];
}

- (void)adFailedWithError:(NSError *)error
{
  [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adError
{
  NSError *error = [NSError errorWithDomain:@"spotx-mopub-ios" code:0 userInfo:_info];
  [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adLoaded
{
  [self.delegate interstitialCustomEvent:self didLoadAd:_adId];
}

- (void)adCompleted
{
  [self.delegate interstitialCustomEventWillDisappear:self];
  [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)adClosed
{
  [self.delegate interstitialCustomEventWillDisappear:self];
  [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)adClicked
{
    dispatch_once(&_clickOnce, ^{
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    });
}

@end
