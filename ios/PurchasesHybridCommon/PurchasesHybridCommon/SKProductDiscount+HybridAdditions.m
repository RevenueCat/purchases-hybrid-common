//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "SKProduct+HybridAdditions.h"
#import "SKProductDiscount+HybridAdditions.h"

API_AVAILABLE(ios(11.2), macos(10.13.2))
@implementation SKProductDiscount (RCPurchases)

- (nullable NSString *)rc_currencyCode {
    if(@available(iOS 10.0, tvOS 10.0, macOS 10.12, *)) {
        return self.priceLocale.currencyCode;
    } else {
        return [self.priceLocale objectForKey:NSLocaleCurrencyCode];
    }
}

- (NSDictionary *)rc_dictionary
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = self.priceLocale;
    
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{
        @"price": @(self.price.floatValue),
        @"priceString": [formatter stringFromNumber:self.price],
        @"period": [SKProduct rc_normalizedSubscriptionPeriod:self.subscriptionPeriod],
        @"periodUnit": [SKProduct rc_normalizedSubscriptionPeriodUnit:self.subscriptionPeriod.unit],
        @"periodNumberOfUnits": @(self.subscriptionPeriod.numberOfUnits),
        @"cycles": @(self.numberOfPeriods)
    }];
    
    if (@available(iOS 12.2, tvOS 12.2, macOS 10.14.4, *)) {
        if (self.identifier) {
            d[@"identifier"] = self.identifier;
        }
    }
    
    return d;
}

@end
