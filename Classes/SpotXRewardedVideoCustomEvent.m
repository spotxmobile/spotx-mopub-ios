//
//  Copyright (c) 2017 SpotXchange, Inc. All rights reserved.
//

#import "SpotX/SpotX.h"

#import "SpotXMoPubError.h"
#import "SpotXRewardedVideoCustomEvent.h"
#import "SpotXInstanceMediationSettings.h"
#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoError.h"

@interface SpotXRewardedVideoCustomEvent () <SpotXAdPlayerDelegate>
@end

@implementation SpotXRewardedVideoCustomEvent {
  NSString *_apikey;
  NSString *_adId;
  NSDictionary *_info;
  SpotXInterstitialAdPlayer *_adPlayer;
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
  _apikey = [SpotX apiKey];

  // if the ChannelID and/or API key is sepcified in the mediation settings, use it instead
  SpotXInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[SpotXInstanceMediationSettings class]];
  if (settings != nil) {
    if(settings.channel_id.length){
      channel_id = settings.channel_id;
    }
    if(settings.apikey.length){
      _apikey = settings.apikey;
    }
  }
  
  if (!_apikey.length) {
    NSError *error = [NSError errorWithDomain:SPXMoPubErrorDomain
                                         code:kSPXMoPubMissingAPIKeyError
                                     userInfo:@{NSLocalizedDescriptionKey:@"apikey is required"}];
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    return;
  }

  if (!channel_id.length) {
    NSError *error = [NSError errorWithDomain:SPXMoPubErrorDomain
                                         code:kSPXMoPubMissingChannelError
                                     userInfo:@{NSLocalizedDescriptionKey:@"channel_id is required"}];
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    return;
  }
  
  _isLoaded = NO;
  
  _adPlayer = [[SpotXInterstitialAdPlayer alloc] init];
  _adPlayer.delegate = self;
  [_adPlayer load];
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
    [_adPlayer start];
  }
  else {
    NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
  }
}

- (void)handleCustomEventInvalidated
{
  _isLoaded = NO;
  _adPlayer = nil;
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
  [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

#pragma mark - SpotXAdPlayerDelegate

- (SpotXAdRequest *)requestForPlayer:(SpotXAdPlayer *)player {
  SpotXAdRequest *request = [[SpotXAdRequest alloc] initWithApiKey:_apikey];
  request.channel = [_info[@"channel_id"] description];
  NSDictionary* paramDict = _info[@"params"];
  for(NSString* param in paramDict.keyEnumerator){
    [request setParam:param value:paramDict[param]];
  }
  return request;
}

- (void)spotx:(SpotXAdPlayer *)player didLoadAds:(SpotXAdGroup *)group error:(NSError *)error {
  dispatch_async(dispatch_get_main_queue(), ^{
    _isLoaded = YES;
    if(group.ads.count > 0){
      [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    } else {
      [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
  });
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
{
  [_adPlayer start];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
  });
}

- (void)spotx:(SpotXAdPlayer *)player adError:(SpotXAd *)ad error:(NSError *)error
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
  });
}

- (void)spotx:(SpotXAdPlayer *)player adGroupComplete:(SpotXAdGroup * _Nonnull)group
{
  dispatch_async(dispatch_get_main_queue(), ^{
    // ad completed - give reward
    [self finishAdWithReward:YES];
  });
}

- (void)spotx:(SpotXAdPlayer *)player adClicked:(SpotXAd *)ad
{
  dispatch_once(&_clickOnce, ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
    });
  });
}


@end
