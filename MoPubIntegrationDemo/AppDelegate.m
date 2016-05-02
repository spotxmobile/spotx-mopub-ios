//
//  Copyright © 2016 spotxchange. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  // color nav and status bar
  UIColor *lightBlueColor = [[UIColor alloc] initWithRed:61/255.0f green:196/255.0f blue:255/255.0f alpha:1.0f];
  [[UINavigationBar appearance] setBarTintColor:lightBlueColor];
  [[UINavigationBar appearance] setTranslucent:NO];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

  return YES;
}

@end
