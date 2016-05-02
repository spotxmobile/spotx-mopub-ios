//
//  Copyright © 2016 spotxchange. All rights reserved.
//

#import "RootViewController.h"
#import "SpotX/SpotX.h"
#import "MoPub.h"

@interface RootViewController ()
@end

@implementation RootViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"SpotX Plugin";
  [self setUpTableFooter];
  [self setNeedsStatusBarAppearanceUpdate];
}

/**
 Sets the tableView's footer to display SpotX's and MoPub's SDK versions
 */
- (void) setUpTableFooter
{
  CGRect footFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50);
  UITableViewHeaderFooterView *tableFooter = [[UITableViewHeaderFooterView alloc] initWithFrame:footFrame];
  tableFooter.textLabel.textAlignment = NSTextAlignmentCenter;
  tableFooter.textLabel.numberOfLines = 2;
  tableFooter.textLabel.text = [NSString stringWithFormat:@"SpotX SDK Version: %@\nMoPub SDK Version: %@", [SpotX version], [[MoPub sharedInstance] version]];
  tableFooter.textLabel.font = [UIFont systemFontOfSize:12.0];
  tableFooter.textLabel.textColor = [UIColor colorWithRed:120/255.0f green:120/255.0f blue:125/255.0f alpha:1.0f];
  self.tableView.tableFooterView = tableFooter;
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [[UITableViewCell alloc] init];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f  blue:252/255.0f  alpha:1.0f];
  switch(indexPath.row){
    case 0:
      cell.textLabel.text = @"MoPub Interstitial";
      cell.imageView.image = [[UIImage imageNamed:@"interstitial"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
      break;
    case 1:
      cell.textLabel.text = @"MoPub Rewarded Video";
      cell.imageView.image = [[UIImage imageNamed:@"rewarded"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      break;
  }
  cell.imageView.tintColor = [UIColor colorWithRed:60/255.0f green:60/255.0f  blue:63/255.0f  alpha:1.0f];
  cell.textLabel.textColor = [UIColor colorWithRed:60/255.0f green:60/255.0f  blue:63/255.0f  alpha:1.0f];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  UIViewController *vc;
  switch(indexPath.row){
    case 0:
      vc = [sb instantiateViewControllerWithIdentifier:@"InterstitialAdVC"];
      break;
    case 1:
      vc = [sb instantiateViewControllerWithIdentifier:@"RewardedVideoVC"];
      break;
  }
  [[self navigationController] pushViewController:vc animated:YES];
}

@end
