//
//  Copyright (c) 2015 SpotXchange, Inc. All rights reserved.
//

#import "SpotXInterstitial.h"
#import "AdManager/SpotX.h"


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
  _adId = [[NSProcessInfo processInfo] globallyUniqueString];
  _info = info;

  NSString *channelID = info[@"channel_id"];

  if (!channelID.length) {
    NSError *error = [NSError errorWithDomain:@"spotx-mopub-ios"
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey:@"channel_id is required"}];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    return;
  }

  // Initialize SpotX SDK exactly once
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSString *category = info[@"iab_category"];
    NSString *section = info[@"iab_section"];
    NSString *url = info[@"appstore_url"];
    NSString *domain = info[@"app_domain"];
    [SpotX initializeWithApiKey:nil category:category section:section domain:domain url:url];
  });

  _adView = [[SpotXView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _adView.delegate = self;

  _adView.channelID = [channelID description];
  _adView.params = info[@"params"];
  [self applySettings:_adView.settings info:info];

  [_adView startLoading];
  [_adView show];

  [self.delegate interstitialCustomEventWillAppear:self];
  [self.delegate interstitialCustomEventDidAppear:self];
}

- (BOOL)validateCustomEventInfo:(NSDictionary *)info error:(NSError **)error
{
  NSArray *required = @[ @"channel_id" ];

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

- (void)applySettings:(id)settings info:(NSDictionary *)info
{
  void (^optional)(NSString*,NSString*) = ^(NSString *key, NSString *value) {
    if (value.length) {
      @try {
        [settings setValue:@([value boolValue]) forKey:key];
      }
      @finally {}
    }
  };


  optional(@"useHTTPS", info[@"use_https"]);
  optional(@"useNativeBrowser", info[@"use_native_browser"]);
  optional(@"allowCalendar", info[@"allow_calendar"]);
  optional(@"allowPhone", info[@"allow_phone"]);
  optional(@"allowSMS", info[@"allow_sms"]);
  optional(@"allowStorage", info[@"allow_storage"]);
  optional(@"autoplay", info[@"autoplay"]);
  optional(@"skippable", info[@"skippable"]);
  optional(@"trackable", info[@"trackable"]);
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
  [_viewController dismissViewControllerAnimated:YES completion:^(){
      [self.delegate interstitialCustomEventDidDisappear:self];
  }];
}

- (void)adClosed
{
  [self.delegate interstitialCustomEventWillDisappear:self];
  [_viewController dismissViewControllerAnimated:YES completion:^(){
    [self.delegate interstitialCustomEventDidDisappear:self];
  }];
}

- (void)adClicked
{
    dispatch_once(&_clickOnce, ^{
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    });
}

@end
