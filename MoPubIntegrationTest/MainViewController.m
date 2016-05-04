//
//  Copyright (c) 2015 SpotXchange, Inc. All rights reserved.
//

#import "MainViewController.h"
#import "SpotX/SpotX.h"

@implementation MainViewController
{
  NSArray *_adUnitIds;
  NSArray *_adUnitNames;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _adUnitIds = @[
    @"034709d6e1a4493d8b5da8c7a3e0249c",
    @"ae9908586f764104a61ff96c99556490",
    @"45fd9477778b4ae1aa58d31a1514e87b",
    @"6621dee45d9a41568623eb7aaa8c52de",
    @"ec9e43b19e8646c19f28f08581153472",
    @"3736c08a045147a4be52477f961a1ec3"
  ];

  _adUnitNames = @[
     @"85394 - Cattitude",
     @"93029 - Mixpo",
     @"116219 - Telemetry",
     @"103105 - Sizmek",
     @"103316 - Innovid",
     @"121277 - Snowmobile SSL"
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
  cell.detailTextLabel.textColor = [UIColor grayColor];
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
