//
//  Copyright (c) 2015 Lance Niles. All rights reserved.
//

#import "LogViewController.h"
#import "AppDelegate.h"

@implementation LogViewController {
  dispatch_source_t _watcher;
  NSMutableData *_buffer;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _buffer = [[NSMutableData alloc] init];
  
  NSString *logfile = [(AppDelegate *)[[UIApplication sharedApplication] delegate] logfile];
  _watcher = [self watcher:logfile];
}

- (void)dealloc
{
  if (_watcher) {
    dispatch_source_cancel(_watcher);
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if (_watcher) {
    dispatch_resume(_watcher);
  }
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  if (_watcher) {
    dispatch_suspend(_watcher);
  }
}

- (dispatch_source_t)watcher:(NSString *)filename
{
  int fd = open(filename.UTF8String, O_RDONLY);
  if (fd == -1) {
    return nil;
  }

  fcntl(fd, F_SETFL, O_NONBLOCK);

  dispatch_source_t watcher = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, dispatch_get_main_queue());
  if (!watcher) {
    close(fd);
    return nil;
  }

  dispatch_source_set_event_handler(watcher, ^{

    size_t estimated = dispatch_source_get_data(watcher);

    NSMutableData *data = [NSMutableData dataWithLength:estimated];

    ssize_t actual = read(fd, data.mutableBytes, (estimated));

    [_buffer appendBytes:data.bytes length:actual];
    [self render];
  });

  dispatch_source_set_cancel_handler(watcher, ^{
    close(fd);
  });

  return watcher;


}

- (void)render {
  [self.webview loadData:_buffer MIMEType:@"text/plain" textEncodingName:@"UTF-8" baseURL:nil];
}

@end
