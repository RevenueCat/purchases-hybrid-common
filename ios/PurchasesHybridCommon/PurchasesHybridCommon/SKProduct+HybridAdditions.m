//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "SKProduct+HybridAdditions.h"
#import "SKProductDiscount+HybridAdditions.h"

@import RevenueCat;

@implementation RCStoreProduct (RCPurchases)

- (nullable NSString *)rc_currencyCode {
    if(@available(iOS 10.0, tvOS 10.0, macOS 10.12, *)) {
        // JOSH: this feels bad to use sk1 product
        return self.sk1Product.priceLocale.currencyCode;
    } else {
        // JOSH: this feels bad to use sk1 product
        return [self.sk1Product.priceLocale objectForKey:NSLocaleCurrencyCode];
    }
}

- (NSDictionary *)rc_dictionary
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    // JOSH: this feels bad to use sk1 product
    formatter.locale = self.sk1Product.priceLocale;
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{
                        @"identifier": self.productIdentifier ?: @"",
                        @"description": self.localizedDescription ?: @"",
                        @"title": self.localizedTitle ?: @"",
                        // JOSH: sk1 used for now because Decimal is not getting bridged over from swift properly
                        @"price": @([self.sk1Product.price floatValue]),
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
        // JOSH: this needs work but has issues because of Decimal being used in swift
        if (self.introductoryDiscount) {
            d[@"intro_price"] = @(self.sk1Product.introductoryPrice.price.floatValue);
            d[@"intro_price_string"] = self.localizedIntroductoryPriceString;
            d[@"intro_price_period"] =
                [RCStoreProduct rc_normalizedSubscriptionPeriod:self.introductoryDiscount.subscriptionPeriod];
            d[@"intro_price_period_unit"] =
                [RCStoreProduct rc_normalizedSubscriptionPeriod:self.introductoryDiscount.subscriptionPeriod];
            d[@"intro_price_period_number_of_units"] = @(self.introductoryDiscount.subscriptionPeriod.unit);
            // JOSH: RCStoreProductDiscount missing numberOfPeriods and has higher sk1Discunt requires iOS 12.2???
            d[@"intro_price_cycles"] = @(self.introductoryDiscount.sk1Discount.numberOfPeriods);
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
