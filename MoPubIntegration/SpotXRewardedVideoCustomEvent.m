//
//  Copyright (c) 2016 SpotXchange, Inc. All rights reserved.
//

#import "SpotX/SpotX.h"

#import "SpotXRewardedVideoCustomEvent.h"
#import "SpotXInstanceMediationSettings.h"
#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoError.h"

@interface SpotXRewardedVideoCustomEvent () <SpotXAdDelegate>
@end

@implementation SpotXRewardedVideoCustomEvent {
  NSString *_adId;
  NSDictionary *_info;
  SpotXView *_adView;
  UIViewController *_viewController;
  dispatch_once_t _clickOnce;
  BOOL _isLoaded;
}

#pragma mark - MoPub Hooks

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
  _adId = [[NSProcessInfo processInfo] globallyUniqueString];
  _info = info;

  NSString *channel_id = info[@"channel_id"];

  // if the ChannelID is sepcified in the mediation settings, use it instead
  SpotXInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[SpotXInstanceMediationSettings class]];
  if (nil != settings) {
    channel_id = settings.channel_id;
  }

  if (!channel_id.length) {
    NSError *error = [NSError errorWithDomain:@"spotx-mopub-ios"
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey:@"channel_id is required"}];
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
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

  _adView = [[SpotXView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _adView.delegate = self;

  // create config options
  NSMutableDictionary *config = [[NSMutableDictionary alloc] init];

  // helper function to remove nil and zero value config params
  void (^optional)(NSString*,NSString*) = ^(NSString *key, NSString *value) {
    if(!(value == nil || [value isKindOfClass:[NSNull class]]
         || ([value respondsToSelector:@selector(length)]
             && [(NSData *)value length] == 0)
         || ([value respondsToSelector:@selector(count)]
             && [(NSArray *)value count] == 0)
         || ([value respondsToSelector:@selector(boolValue)] // checks if the NSString is of type __NSCFBoolean
             && [(NSString *)value boolValue] == 0)
         )){
      config[key] = value;
    }
  };

  // Set channel and config
  [_adView setChannelID:[channel_id description]];
  _adView.params = info[@"params"];
  optional(@"useHTTPS",info[@"use_https"]);
  optional(@"allowCalendar",info[@"allow_calendar"]);
  optional(@"allowPhone",info[@"allow_phone"]);
  optional(@"allowSMS",info[@"allow_sms"]);
  optional(@"allowStorage",info[@"allow_storage"]);
  optional(@"autoplay",info[@"autoplay"]);
  optional(@"skippable",info[@"skippable"]);
  optional(@"trackable",info[@"trackable"]);
  [_adView setConfig:[config copy]];

  _isLoaded = NO;
  [_adView startLoading];
}

- (BOOL)hasAdAvailable
{
  return _isLoaded;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
  if ([self hasAdAvailable]) {
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    _viewController = viewController;
    [_adView show];
  }
  else {
    NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
  }
}

- (void)handleCustomEventInvalidated
{
  _isLoaded = NO;
  _adView = nil;
}

- (void)handleAdPlayedForCustomEventNetwork
{
  // If we no longer have an ad available, report back up to the application that this ad expired.
  // We receive this message only when this ad has reported an ad has loaded and another ad unit
  // has played a video for the same ad network.
  if (![self hasAdAvailable]) {
    [self.delegate rewardedVideoDidExpireForCustomEvent:self];
  }
}

- (void)finishAdWithReward:(BOOL)reward {
  _isLoaded = NO;
  if (reward) {
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[[MPRewardedVideoReward alloc] initWithCurrencyAmount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)]];
  }

  [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
  [_viewController dismissViewControllerAnimated:YES completion:^(){
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
  }];
}

#pragma mark - SpotXAdDelegate

- (void)presentViewController:(UIViewController *)viewControllerToPresent
{
  [self.delegate rewardedVideoDidAppearForCustomEvent:self];
  [_viewController presentViewController:viewControllerToPresent animated:YES completion:nil];
}

- (void)adFailedWithError:(NSError *)error
{
  [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)adError
{
  NSError *error = [NSError errorWithDomain:@"spotx-mopub-ios" code:0 userInfo:_info];
  [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)adLoaded
{
  _isLoaded = YES;
  [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)adCompleted
{
  // ad completed - give reward
  [self finishAdWithReward:YES];
}

- (void)adClosed
{
  // ad closed - give reward?
  [self finishAdWithReward:YES];
}

- (void)adClicked
{
  dispatch_once(&_clickOnce, ^{
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
  });
}


@end