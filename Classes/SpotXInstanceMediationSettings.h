//
//  Copyright (c) 2017 SpotXchange, Inc. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MPMediationSettingsProtocol.h"
#endif

/*
 * `SpotXInstanceMediationSettings` allows the application to provide per-instance properties
 * to configure aspects of SpotX ads. See `MPMediationSettingsProtocol` to see how mediation settings
 * are used.
 */

@interface SpotXInstanceMediationSettings : NSObject <MPMediationSettingsProtocol>

/*
 * An NSString containing the app's SpotX API key.
 */
@property (nonatomic, copy) NSString *apikey;

/*
 * An NSString containing the SpotX Channel ID.
 */
@property (nonatomic, copy) NSString *channel_id;

@end
