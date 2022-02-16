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
    if(@available(iOS 10.0, tvOS 10.0, macOS 10.12, *)) {
        // JOSH: find way to get currency code without sk1discount
        return self.sk1Discount.priceLocale.currencyCode;
    } else {
        // JOSH: find way to get currency code without sk1discount
        return [self.sk1Discount.priceLocale objectForKey:NSLocaleCurrencyCode];
    }
}

- (NSDictionary *)rc_dictionary
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    // JOSH: need sk1discount to get pricelocal
    formatter.locale = self.sk1Discount.priceLocale;
    
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{
        // JOSH: need sk1discount becuase Decimal doesn't bridge from swift
        @"price": @(self.sk1Discount.price.floatValue),
        @"priceString": [formatter stringFromNumber:self.sk1Discount.price],
        @"period": [RCStoreProduct rc_normalizedSubscriptionPeriod:self.subscriptionPeriod],
        @"periodUnit": [RCStoreProduct rc_normalizedSubscriptionPeriod:self.subscriptionPeriod],
        @"periodNumberOfUnits": @(self.subscriptionPeriod.value),
        // JOSH: number of periods not available
        @"cycles": @(self.sk1Discount.numberOfPeriods)
    }];
    
    if (@available(iOS 12.2, tvOS 12.2, macOS 10.14.4, *)) {
        if (self.offerIdentifier) {
            d[@"identifier"] = self.offerIdentifier;
        }
    }
    
    return d;
}

@end
