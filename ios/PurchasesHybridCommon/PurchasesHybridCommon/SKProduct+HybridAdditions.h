//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import <StoreKit/StoreKit.h>
@import RevenueCat;

@interface RCStoreProduct (HybridAdditions)

- (NSDictionary *)rc_dictionary;
+ (NSString *)rc_normalizedSubscriptionPeriod:(RCSubscriptionPeriod *)subscriptionPeriod API_AVAILABLE(ios(11.2), macos(10.13.2), tvos(11.2));
+ (NSString *)rc_normalizedSubscriptionPeriodUnit:(RCSubscriptionPeriod *)subscriptionPeriodUnit API_AVAILABLE(ios(11.2), macos(10.13.2), tvos(11.2));

@end
