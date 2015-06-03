//
//  Copyright (c) 2015 SpotXchange, Inc. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController
{
  NSArray *_adUnitIds;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _adUnitIds = @[
    @"cf37d12f721c438b8a667577d64ecd8d",
    @"e63a3fd0f15f4e74a997cd7d3beed4d9",
    @"edf853f847a5451d9494e8442d2d3346"
  ];

  self.clearsSelectionOnViewWillAppear = YES;
  self.tableView.allowsMultipleSelection = NO;
  self.view.autoresizesSubviews = YES;
  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

- (void)playAd:(NSString *)adUnitId
{

  MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:adUnitId];
  [interstitial setDelegate:self];
  [interstitial loadAd];
}

- (void)alert:(NSString *)format, ...
{
  va_list args;
  va_start(args, format);

  NSString *title = NSLocalizedString(@"SpotX MoPub Integration", nil);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:args];

  va_end(args);


  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _adUnitIds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdUnitId"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AdUnitId"];
  }

  cell.textLabel.text = _adUnitIds[indexPath.row];

  return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *adUnitId = _adUnitIds[indexPath.row];
  [self playAd:adUnitId];
}


#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
  [interstitial showFromViewController:self];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, interstitial.adUnitId);
  [self alert:@"Failed to load ad %@", interstitial.adUnitId];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, interstitial.adUnitId);
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial
{
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, interstitial.adUnitId);
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial
{
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, interstitial.adUnitId);
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, interstitial.adUnitId);
  [interstitial setDelegate:nil];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, interstitial.adUnitId);
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial
{
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, interstitial.adUnitId);
}

@end
