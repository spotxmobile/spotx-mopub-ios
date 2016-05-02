//
//  Copyright © 2016 spotxchange. All rights reserved.
//

#import "InterstitialAdVC.h"

@interface InterstitialAdVC ()

@property (weak, nonatomic) IBOutlet UITextField *adUnitTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnInitialize;
@property (weak, nonatomic) IBOutlet UIButton *btnLoadAd;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayAd;
@property (weak, nonatomic) IBOutlet UIButton *btnClearLog;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (strong) MPInterstitialAdController *adController;
@property (strong) NSString *currentAdUnitId;

@property BOOL adInitialized;
@property BOOL adLoaded;

@end


@implementation InterstitialAdVC

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Interstitial Ad";

  _adInitialized = NO;
  _adLoaded = NO;
  _btnLoadAd.enabled = NO;
  _btnPlayAd.enabled = NO;
  _btnLoadAd.alpha = 0.3;
  _btnPlayAd.alpha = 0.3;
  _currentAdUnitId = @"034709d6e1a4493d8b5da8c7a3e0249c"; // SpotX default Interstitial Ad Unit ID
  _adUnitTextField.text = _currentAdUnitId;
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
  if([self isAdUnitEmpty]){
    [self logToScreen:@"Error: Ad Unit ID can't be empty"];
    return;
  }
  _currentAdUnitId = _adUnitTextField.text;
  [self logToScreen:[NSString stringWithFormat:@"> Initializing: %@", _currentAdUnitId]];

  // initialize our MoPub Ad Controller with our ad unit od
  _adController = [MPInterstitialAdController interstitialAdControllerForAdUnitId:_currentAdUnitId];

  // check if init was successful
  if(_adController != nil){
    _adController.delegate = self; // set ourselves as the delegate
    _adInitialized = YES;
    _btnLoadAd.enabled = YES;
    _btnLoadAd.alpha = 1.0;
  }
  else{
    [self logToScreen:@"Error: Failed to initialize"];
  }
}

- (IBAction)btnLoadAdPressed:(id)sender
{
  if(!_adInitialized){
    [self logToScreen:@"Error: Ad not initialized"];
    return;
  }
  [self logToScreen:[NSString stringWithFormat:@"> Loading: %@", _currentAdUnitId]];

  // load MoPub interstitial ad
  [_adController loadAd];
}

- (IBAction)btnPlayAdPressed:(id)sender
{
  if(!_adLoaded){
    [self logToScreen:@"Error: Ad not loaded"];
    return;
  }
  [self logToScreen:[NSString stringWithFormat:@"> Playing: %@", _currentAdUnitId]];

  // play MoPub interstitial ad
  [_adController showFromViewController:self];
}

- (IBAction)btnClearLogPressed:(id)sender
{
  _logTextView.text = @"";
}


#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
  [self logToScreen:@"> Ad Loaded"];
  _adLoaded = YES;
  _btnPlayAd.enabled = YES;
  _btnPlayAd.alpha = 1.0;
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
  [self logToScreen:@"Error: Ad failed to load"];
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
  [self logToScreen:@"> Ad Disappeared"];
  _adLoaded = NO;
  _btnPlayAd.enabled = NO;
  _btnPlayAd.alpha = 0.3;
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
  [self logToScreen:@"> Ad Expired"];
  _adLoaded = NO;
  _btnPlayAd.enabled = NO;
  _btnPlayAd.alpha = 0.3;
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial
{
  [self logToScreen:@"> Ad Clicked"];
}

@end
