//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "SKProduct+HybridAdditions.h"
#import "SKProductDiscount+HybridAdditions.h"
@import RevenueCat;

API_AVAILABLE(ios(11.2), macos(10.13.2))
@implementation RCStoreProductDiscount (RCPurchases)

- (nullable NSString *)rc_currencyCode {
    return self.currencyCode;
}

- (NSDictionary *)rc_dictionary
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{
        @"price": self.price,
        @"priceString": self.localizedPriceString,
        @"period": [RCStoreProduct rc_normalizedSubscriptionPeriod:self.subscriptionPeriod],
        @"periodUnit": [RCStoreProduct rc_normalizedSubscriptionPeriod:self.subscriptionPeriod],
        @"periodNumberOfUnits": @(self.subscriptionPeriod.value),
        @"cycles": @(self.subscriptionPeriod.value)
    }];
    
    if (@available(iOS 12.2, tvOS 12.2, macOS 10.14.4, *)) {
        if (self.offerIdentifier) {
            d[@"identifier"] = self.offerIdentifier;
        }
    }
    
    return d;
}

@end
