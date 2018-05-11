//
//  Copyright (c) 2017 SpotXchange, Inc. All rights reserved.
//

#import "SpotX/SpotX.h"

#import "SpotXInterstitial.h"
#import "SpotXMoPubError.h"

@interface SpotXInterstitial () <SpotXAdPlayerDelegate>
@end

@implementation SpotXInterstitial {
  NSString *_apiKey;
  NSString *_adId;
  NSDictionary *_info;
  SpotXInterstitialAdPlayer *_adPlayer;
  UIViewController *_viewController;
  dispatch_once_t _clickOnce;
}


#pragma mark - MoPub Hooks

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
  _adId = [[NSProcessInfo processInfo] globallyUniqueString];
  _info = info;

  NSString *channelID = info[@"channel_id"];
  _apiKey = [SpotX apiKey];
  
  if (!_apiKey.length) {
    NSError *error = [NSError errorWithDomain:SPXMoPubErrorDomain
                                         code:kSPXMoPubMissingAPIKeyError
                                     userInfo:@{NSLocalizedDescriptionKey:@"MoPub requires apiKey to be set via [SpotX setApiKey:]"}];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    return;
  }

  if (!channelID.length) {
    NSError *error = [NSError errorWithDomain:SPXMoPubErrorDomain
                                         code:kSPXMoPubMissingChannelError
                                     userInfo:@{NSLocalizedDescriptionKey:@"channel_id is required"}];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    return;
  }

  _adPlayer = [[SpotXInterstitialAdPlayer alloc] init];
  _adPlayer.delegate = self;
  
  [_adPlayer load];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
  _viewController = rootViewController;
  [_adPlayer start];
  [self.delegate interstitialCustomEventWillAppear:self];
  [self.delegate interstitialCustomEventDidAppear:self];
}


#pragma mark - SpotXAdDelegate

- (SpotXAdRequest *)requestForPlayer:(SpotXAdPlayer *)player {
  SpotXAdRequest *request = [[SpotXAdRequest alloc] initWithApiKey:_apiKey];
  request.channel = [_info[@"channel_id"] description];
  NSDictionary* paramDict = _info[@"params"];
  for(NSString* param in paramDict.keyEnumerator){
    [request setParam:param value:paramDict[param]];
  }
  return request;
}

- (void)spotx:(SpotXAdPlayer *)player didLoadAds:(SpotXAdGroup *)group error:(NSError *)error {
  dispatch_async(dispatch_get_main_queue(), ^{
    if(group.ads.count > 0){
      [self.delegate interstitialCustomEvent:self didLoadAd:_adId];
    } else {
      [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
  });
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
{
  [_adPlayer start];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
  });
}

- (void)spotx:(SpotXAdPlayer *)player adError:(SpotXAd *)ad error:(NSError *)error
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
  });
}

- (void)spotx:(SpotXAdPlayer *)player adGroupComplete:(SpotXAdGroup * _Nonnull)group
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
  });
}

- (void)spotx:(SpotXAdPlayer *)player adClicked:(SpotXAd *)ad
{
    dispatch_once(&_clickOnce, ^{
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
      });
    });
}

@end
