//
//  Copyright © 2018 SpotX, Inc. All rights reserved.
//

@import Foundation;

/** Error domain for SpotX-MoPub-Plugin */
static const NSErrorDomain _Nonnull SPXMoPubErrorDomain = @"spotx-mopub-ios";

/** Error codes for SPXMoPubErrorDomain */
typedef NS_ENUM(NSInteger, SPXMoPubError) {
  kSPXMoPubMissingAPIKeyError   = -1,
  kSPXMoPubMissingChannelError  = -2,
};
