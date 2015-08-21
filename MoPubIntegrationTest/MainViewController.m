//
//  Copyright (c) 2015 SpotXchange, Inc. All rights reserved.
//

#import "MainViewController.h"
#import "SpotX.h"

@implementation MainViewController
{
  NSArray *_adUnitIds;
  NSArray *_adUnitNames;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _adUnitIds = @[
    @"f3b430cde0604312a1319a03eb524b1b",
  ];

  _adUnitNames = @[
     @"InnoVid VPAID",
   ];

  self.clearsSelectionOnViewWillAppear = YES;
  self.tableView.allowsMultipleSelection = NO;
  self.view.autoresizesSubviews = YES;
  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

  self.sdkVersion.title = [NSString stringWithFormat:@"SDK v%@", [SpotX version]];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  NSArray *selection = [self.tableView indexPathsForSelectedRows];
  for (NSIndexPath *indexPath in selection) {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  }
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

  NSString *title =  NSLocalizedString(@"SpotX MoPub Integration", nil);
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
  cell.textLabel.text = _adUnitNames[indexPath.row];
  cell.detailTextLabel.text = _adUnitIds[indexPath.row];

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
