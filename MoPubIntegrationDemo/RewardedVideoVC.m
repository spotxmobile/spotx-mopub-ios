//
//  Copyright © 2016 spotxchange. All rights reserved.
//

#import "RewardedVideoVC.h"

@interface RewardedVideoVC ()

@property (weak, nonatomic) IBOutlet UITextField *adUnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *mediationSettingsTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnInitialize;
@property (weak, nonatomic) IBOutlet UIButton *btnLoadAd;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayAd;
@property (weak, nonatomic) IBOutlet UIButton *btnClearLog;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (strong) NSString *currentAdUnitId;
@property (strong) NSString *currentMediationSettings;

@property BOOL adInitialized;
@property BOOL adLoaded;

@end

@implementation RewardedVideoVC

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Rewarded Video";

  _adInitialized = NO;
  _adLoaded = NO;
  _btnLoadAd.enabled = NO;
  _btnPlayAd.enabled = NO;
  _btnLoadAd.alpha = 0.3;
  _btnPlayAd.alpha = 0.3;
  _currentAdUnitId = @"e3b23c46dd6a41d1a2f049eea9ca2f81"; // SpotX default Rewarded Video Ad Unit ID
  _adUnitTextField.text = _currentAdUnitId;
  _currentMediationSettings = @"{ \"channel_id\": \"85394\" }"; // SpotX default channel ID
  _mediationSettingsTextField.text = _currentMediationSettings;
}

- (void)logToScreen:(NSString *)msg
{
  NSString *message = [msg stringByAppendingString:@"\n"];
  NSString *currentLog = _logTextView.text;
  _logTextView.scrollEnabled = NO;
  _logTextView.text = [currentLog stringByAppendingString:message];
  _logTextView.textColor = [UIColor colorWithRed:120/255.0f green:120/255.0f blue:130/255.0f alpha:1.0f];
  _logTextView.scrollEnabled = YES;
  if([_logTextView.text length] > 0){
    [_logTextView scrollRangeToVisible:NSMakeRange([_logTextView.text length] - 1, 1)];
  }
}

- (BOOL)isAdUnitEmpty
{
  return ([_adUnitTextField.text length] == 0 ||
          ![[_adUnitTextField.text stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]] length]);
}


#pragma mark - Button Actions

- (IBAction)btnInitializedPressed:(id)sender
{
  [self logToScreen:@"> Initializing interface"];
  // initialize MoPub Rewarded Video
  [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:nil delegate:self];
  _btnLoadAd.enabled = YES;
  _btnLoadAd.alpha = 1.0;
  _adInitialized = YES;
}

- (IBAction)btnLoadAdPressed:(id)sender
{
  if(!_adInitialized){
    [self logToScreen:@"Error: Ad not initialized"];
    return;
  }
  if([self isAdUnitEmpty]){
    [self logToScreen:@"Error: Ad Unit ID can't be empty"];
    return;
  }
  _currentAdUnitId = _adUnitTextField.text;
  [self logToScreen:[NSString stringWithFormat:@"> Loading: %@", _currentAdUnitId]];

  // Parse json mediation settings
  NSString *msettings = _mediationSettingsTextField.text;
  NSData *mdata = [msettings dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error;
  NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:mdata options:NSJSONReadingMutableContainers error:&error];

  // check if json is correct
  if(error != nil){
    [self logToScreen:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]];
    return;
  }
  // check if json contains a SpotX channel id
  else if(json[@"channel_id"] == nil){
    [self logToScreen:@"Error: Missing channel_id in mediation settings"];
    return;
  }

  // initialize SpotX's mediation settings with given channel id
  SpotXInstanceMediationSettings *spotxsettings = [[SpotXInstanceMediationSettings alloc] init];
  spotxsettings.channel_id = json[@"channel_id"];
  [self logToScreen:[NSString stringWithFormat:@"> Channel ID: %@", spotxsettings.channel_id]];

  // load MoPub rewarded video with mediation settings
  [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:_currentAdUnitId withMediationSettings:@[spotxsettings]];
}

- (IBAction)btnPlayAdPressed:(id)sender
{
  if(!_adLoaded){
    [self logToScreen:@"Error: Ad not loaded"];
    return;
  }
  [self logToScreen:[NSString stringWithFormat:@"> Playing: %@", _currentAdUnitId]];
  // play the loaded MoPub rewarded video ad
  [MPRewardedVideo presentRewardedVideoAdForAdUnitID:_currentAdUnitId fromViewController:self];
}

- (IBAction)btnClearLogPressed:(id)sender
{
  _logTextView.text = @"";
}


#pragma mark - MPRewardedVideoDelegate

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID
{
  [self logToScreen:@"> Ad Loaded"];
  _adLoaded = YES;
  _btnPlayAd.enabled = YES;
  _btnPlayAd.alpha = 1.0;
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error
{
  [self logToScreen:@"Error: Ad failed to load"];
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID
{
  [self logToScreen:@"> Ad Disappeared"];
  _adLoaded = NO;
  _btnPlayAd.enabled = NO;
  _btnPlayAd.alpha = 0.3;
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID
{
  [self logToScreen:@"> Ad Expired"];
  _adLoaded = NO;
  _btnPlayAd.enabled = NO;
  _btnPlayAd.alpha = 0.3;
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward
{
  [self logToScreen:[NSString stringWithFormat:@"> Should reward for: %@", adUnitID]];
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID
{
  [self logToScreen:@"> Ad Clicked"];
}

@end
