//
//  Copyright (c) 2015 SpotXchange, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  NSString *tempdir = NSTemporaryDirectory();
  [[NSFileManager defaultManager] createDirectoryAtPath:tempdir
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];

  NSString *filename = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"log"];
  _logfile = [tempdir stringByAppendingPathComponent:filename];
  [self redirectStdErr:_logfile];
  return YES;
}

- (void)redirectStdErr:(NSString *)filename
{
  freopen([filename fileSystemRepresentation], "a+", stderr);
}

@end
