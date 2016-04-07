//
//  Copyright (c) 2016 SpotXchange, Inc. All rights reserved.
//

#import "SpotX/SpotX.h"
#import "SpotXInterstitial.h"

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
    [SpotX initializeWithApiKey:nil category:category section:section domain:domain url:url config:nil];
  });

  // Init SpotXAdView
  _adView = [[SpotXView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _adView.delegate = self;

  // Set channel and config
  [_adView setChannelID:[channelID description]];
  _adView.params = info[@"params"];
  SpotXConfigurationDict *config = @{
    @"useHTTPS":info[@"use_https"],
    @"allowCalendar":info[@"allow_calendar"],
    @"allowPhone":info[@"allow_phone"],
    @"allowSMS":info[@"allow_sms"],
    @"allowStorage":info[@"allow_storage"],
    @"autoplay":info[@"autoplay"],
    @"skippable":info[@"skippable"],
    @"trackable":info[@"trackable"]
  };
  [_adView setConfig:config];

  // load and go
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
