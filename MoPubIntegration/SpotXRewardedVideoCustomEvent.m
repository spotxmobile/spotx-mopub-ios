//
//  Copyright (c) 2015 SpotXchange, Inc. All rights reserved.
//

#import "SpotXRewardedVideoCustomEvent.h"
#import "SpotXInstanceMediationSettings.h"
#import "AdManager/SpotX.h"


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
    [SpotX initializeWithApiKey:nil category:category section:section domain:domain url:url];
  });

  _adView = [[SpotXView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _adView.delegate = self;

  _adView.channelID = [channel_id description];
  _adView.params = info[@"params"];
  [self applySettings:_adView.settings info:info];

  _isLoaded = NO;
  [_adView startLoading];
}

- (BOOL)hasAdAvailable
{
  return _isLoaded;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
  [self.delegate rewardedVideoWillAppearForCustomEvent:self];
  _viewController = viewController;
  [_adView show];
}

- (void)handleCustomEventInvalidated
{
  _isLoaded = NO;
  _adView = nil;
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
  [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
  [_viewController dismissViewControllerAnimated:YES completion:^(){
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
  }];
}

- (void)adClosed
{
  [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
  [_viewController dismissViewControllerAnimated:YES completion:^(){
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
  }];
}

- (void)adClicked
{
  dispatch_once(&_clickOnce, ^{
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
  });
}


@end