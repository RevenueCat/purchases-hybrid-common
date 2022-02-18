//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "SKProduct+HybridAdditions.h"
#import "SKProductDiscount+HybridAdditions.h"

@import RevenueCat;

@implementation RCStoreProduct (RCPurchases)

- (nullable NSString *)rc_currencyCode {
    return self.currencyCode;
}

- (NSDictionary *)rc_dictionary
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{
                        @"identifier": self.productIdentifier ?: @"",
                        @"description": self.localizedDescription ?: @"",
                        @"title": self.localizedTitle ?: @"",
                        @"price": self.price,
                        @"price_string": self.localizedPriceString,
                        @"currency_code": (self.rc_currencyCode) ? self.rc_currencyCode : [NSNull null]
                        }];
    
    d[@"intro_price"] = [NSNull null];
    d[@"intro_price_string"] = [NSNull null];
    d[@"intro_price_period"] = [NSNull null];
    d[@"intro_price_period_unit"] = [NSNull null];
    d[@"intro_price_period_number_of_units"] = [NSNull null];
    d[@"intro_price_cycles"] = [NSNull null];
    d[@"introPrice"] = [NSNull null];
    
    if (@available(iOS 11.2, tvOS 11.2, macos 10.13.2, *)) {
        if (self.introductoryDiscount) {
            d[@"intro_price"] = self.introductoryDiscount.price;
            d[@"intro_price_string"] = self.localizedIntroductoryPriceString;
            d[@"intro_price_period"] =
                [RCStoreProduct rc_normalizedSubscriptionPeriod:self.introductoryDiscount.subscriptionPeriod];
            d[@"intro_price_period_unit"] =
                [RCStoreProduct rc_normalizedSubscriptionPeriod:self.introductoryDiscount.subscriptionPeriod];
            d[@"intro_price_period_number_of_units"] = @(self.introductoryDiscount.subscriptionPeriod.unit);
            d[@"intro_price_cycles"] = @(self.introductoryDiscount.subscriptionPeriod.value);
            d[@"introPrice"] = self.introductoryDiscount.rc_dictionary;
        }
    }
    
    d[@"discounts"] = [NSNull null];
    
    if (@available(iOS 12.2, tvOS 12.2, macos 10.14.4, *)) {
        d[@"discounts"] = [NSMutableArray new];
        for (RCStoreProductDiscount* discount in self.discounts) {
            [d[@"discounts"] addObject:discount.rc_dictionary];
        }
    }
    
    return d;
}

+ (NSString *)rc_normalizedSubscriptionPeriod:(RCSubscriptionPeriod *)subscriptionPeriod API_AVAILABLE(ios(11.2), macos(10.13.2), tvos(11.2)) {
    NSString *unit;
    switch (subscriptionPeriod.unit) {
        case RCSubscriptionPeriodUnitDay:
            unit = @"D";
            break;
        case RCSubscriptionPeriodUnitWeek:
            unit = @"W";
            break;
        case RCSubscriptionPeriodUnitMonth:
            unit = @"M";
            break;
        case RCSubscriptionPeriodUnitYear:
            unit = @"Y";
            break;
    }
    return [NSString stringWithFormat:@"%@%@%@", @"P", @(subscriptionPeriod.value), unit];
}

+ (NSString *)rc_normalizedSubscriptionPeriodUnit:(RCSubscriptionPeriod *)subscriptionPeriod API_AVAILABLE(ios(11.2), macos(10.13.2), tvos(11.2)) {
    switch (subscriptionPeriod.unit) {
        case RCSubscriptionPeriodUnitDay:
            return @"DAY";
        case RCSubscriptionPeriodUnitWeek:
            return @"WEEK";
        case RCSubscriptionPeriodUnitMonth:
            return @"MONTH";
        case RCSubscriptionPeriodUnitYear:
            return @"YEAR";
    }
}

@end
