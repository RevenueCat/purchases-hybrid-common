//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "RCPurchaserInfo+HybridAdditions.h"
#import "RCEntitlementInfos+HybridAdditions.h"
#import "NSDate+HybridAdditions.h"


@implementation RCPurchaserInfo (HybridAdditions)

- (NSDictionary *)dictionary {
    NSArray *productIdentifiers = self.allPurchasedProductIdentifiers.allObjects;
    NSArray *sortedProductIdentifiers = [productIdentifiers sortedArrayUsingSelector:@selector(compare:)];

    NSMutableDictionary *allExpirations = [NSMutableDictionary new];
    NSMutableDictionary *allExpirationsMillis = [NSMutableDictionary new];
    for (NSString *productIdentifier in sortedProductIdentifiers) {
        NSDate *date = [self expirationDateForProductIdentifier:productIdentifier];
        allExpirations[productIdentifier] = [self formattedAsISO8601OrNull:date];
        allExpirationsMillis[productIdentifier] = [self timeIntervalSince1970OrNull:date];
    }

    NSMutableDictionary *allPurchases = [NSMutableDictionary new];
    NSMutableDictionary *allPurchasesMillis = [NSMutableDictionary new];
    for (NSString *productIdentifier in sortedProductIdentifiers) {
        NSDate *date = [self purchaseDateForProductIdentifier:productIdentifier];
        allPurchases[productIdentifier] = [self formattedAsISO8601OrNull:date];
        allPurchasesMillis[productIdentifier] = [self timeIntervalSince1970OrNull:date];
    }
    NSObject *managementURLorNull = self.managementURL.absoluteString ?: NSNull.null;

    return @{
        @"entitlements": self.entitlements.dictionary,
        @"activeSubscriptions": self.activeSubscriptions.allObjects,
        @"allPurchasedProductIdentifiers": self.allPurchasedProductIdentifiers.allObjects,
        @"latestExpirationDate": [self formattedAsISO8601OrNull:self.latestExpirationDate],
        @"latestExpirationDateMillis": [self timeIntervalSince1970OrNull:self.latestExpirationDate],
        @"firstSeen": self.firstSeen.formattedAsISO8601,
        @"firstSeenMillis": @(self.firstSeen.timeIntervalSince1970),
        @"originalAppUserId": self.originalAppUserId,
        @"requestDate": self.requestDate.formattedAsISO8601,
        @"requestDateMillis": @(self.requestDate.timeIntervalSince1970),
        @"allExpirationDates": allExpirations,
        @"allExpirationDatesMillis": allExpirationsMillis,
        @"allPurchaseDates": allPurchases,
        @"allPurchaseDatesMillis": allPurchasesMillis,
        @"originalApplicationVersion": self.originalApplicationVersion ?: NSNull.null,
        @"originalPurchaseDate": [self formattedAsISO8601OrNull:self.originalPurchaseDate],
        @"originalPurchaseDateMillis": [self timeIntervalSince1970OrNull:self.originalPurchaseDate],
        @"managementURL": managementURLorNull
    };
}

- (NSObject *)timeIntervalSince1970OrNull:(nullable NSDate *)date {
    if (date) {
        return @(date.timeIntervalSince1970);
    } else {
        return NSNull.null;
    }
}

- (NSObject *)formattedAsISO8601OrNull:(nullable NSDate *)date {
    if (date) {
        return date.formattedAsISO8601;
    } else {
        return NSNull.null;
    }
}

@end
