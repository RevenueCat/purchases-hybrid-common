//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "SKProductDiscount+HybridAdditions.h"

@implementation SKProductDiscount (RCPurchases)

- (nullable NSString *)rc_currencyCode {
    if(@available(iOS 10.0, *)) {
        return self.priceLocale.currencyCode;
    } else {
        return [self.priceLocale objectForKey:NSLocaleCurrencyCode];
    }
}

- (NSDictionary *)dictionary
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = self.priceLocale;
    
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{
       
        @"price": @(self.price.floatValue),
        @"priceString": [formatter stringFromNumber:self.price],
        @"period": [self normalizeSubscriptionPeriod:self.subscriptionPeriod],
        @"periodUnit": [self normalizeSubscriptionPeriodUnit:self.subscriptionPeriod.unit],
        @"periodNumberOfUnits": @(self.subscriptionPeriod.numberOfUnits),
        @"cycles": @(self.numberOfPeriods)
    }];
    
    if (@available(iOS 12.2, *)) {
        if (self.identifier) {
            d[@"identifier"] = self.identifier;
        }
    }
    
    return d;
}

- (NSString *)normalizeSubscriptionPeriod:(SKProductSubscriptionPeriod *)subscriptionPeriod API_AVAILABLE(ios(11.2)){
    NSString *unit;
    switch (subscriptionPeriod.unit) {
        case SKProductPeriodUnitDay:
            unit = @"D";
            break;
        case SKProductPeriodUnitWeek:
            unit = @"W";
            break;
        case SKProductPeriodUnitMonth:
            unit = @"M";
            break;
        case SKProductPeriodUnitYear:
            unit = @"Y";
            break;
    }
    return [NSString stringWithFormat:@"%@%@%@", @"P", @(subscriptionPeriod.numberOfUnits), unit];
}

- (NSString *)normalizeSubscriptionPeriodUnit:(SKProductPeriodUnit)subscriptionPeriodUnit API_AVAILABLE(ios(11.2)){
    switch (subscriptionPeriodUnit) {
        case SKProductPeriodUnitDay:
            return @"DAY";
        case SKProductPeriodUnitWeek:
            return @"WEEK";
        case SKProductPeriodUnitMonth:
            return @"MONTH";
        case SKProductPeriodUnitYear:
            return @"YEAR";
    }
}

@end
