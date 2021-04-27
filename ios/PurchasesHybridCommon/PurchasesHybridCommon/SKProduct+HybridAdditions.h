//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (HybridAdditions)

- (NSDictionary *)rc_dictionary;
+ (NSString *)rc_normalizedSubscriptionPeriod:(SKProductSubscriptionPeriod *)subscriptionPeriod API_AVAILABLE(ios(11.2), macos(10.13.2), tvos(11.2));
+ (NSString *)rc_normalizedSubscriptionPeriodUnit:(SKProductPeriodUnit)subscriptionPeriodUnit API_AVAILABLE(ios(11.2), macos(10.13.2), tvos(11.2));

@end
