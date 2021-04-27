//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "RCPurchaserInfo+HybridAdditions.h"
#import "RCEntitlementInfos+HybridAdditions.h"
#import "NSDate+HybridAdditions.h"
#import "RCTransaction+HybridAdditions.h"

@implementation RCPurchaserInfo (HybridAdditions)

- (NSDictionary *)dictionary {
    NSArray *productIdentifiers = self.allPurchasedProductIdentifiers.allObjects;
    NSArray *sortedProductIdentifiers = [productIdentifiers sortedArrayUsingSelector:@selector(compare:)];

    NSMutableDictionary *allExpirations = [NSMutableDictionary new];
    NSMutableDictionary *allExpirationsMillis = [NSMutableDictionary new];
    for (NSString *productIdentifier in sortedProductIdentifiers) {
        NSDate *date = [self expirationDateForProductIdentifier:productIdentifier];
        allExpirations[productIdentifier] = [self formattedAsISO8601OrNull:date];
        allExpirationsMillis[productIdentifier] = [self millisecondsSince1970OrNull:date];
    }

    NSMutableDictionary *allPurchases = [NSMutableDictionary new];
    NSMutableDictionary *allPurchasesMillis = [NSMutableDictionary new];
    for (NSString *productIdentifier in sortedProductIdentifiers) {
        NSDate *date = [self purchaseDateForProductIdentifier:productIdentifier];
        allPurchases[productIdentifier] = [self formattedAsISO8601OrNull:date];
        allPurchasesMillis[productIdentifier] = [self millisecondsSince1970OrNull:date];
    }
    NSObject *managementURLorNull = self.managementURL.absoluteString ?: NSNull.null;
    
    NSMutableArray *nonSubscriptionTransactionsArray = [NSMutableArray new];
    for (RCTransaction *transaction in self.nonSubscriptionTransactions) {
        [nonSubscriptionTransactionsArray addObject:transaction.dictionary];
    }

    return @{
        @"entitlements": self.entitlements.dictionary,
        @"activeSubscriptions": self.activeSubscriptions.allObjects,
        @"allPurchasedProductIdentifiers": self.allPurchasedProductIdentifiers.allObjects,
        @"latestExpirationDate": [self formattedAsISO8601OrNull:self.latestExpirationDate],
        @"latestExpirationDateMillis": [self millisecondsSince1970OrNull:self.latestExpirationDate],
        @"firstSeen": self.firstSeen.rc_formattedAsISO8601,
        @"firstSeenMillis": @(self.firstSeen.rc_millisecondsSince1970AsDouble),
        @"originalAppUserId": self.originalAppUserId,
        @"requestDate": self.requestDate.rc_formattedAsISO8601,
        @"requestDateMillis": @(self.requestDate.rc_millisecondsSince1970AsDouble),
        @"allExpirationDates": allExpirations,
        @"allExpirationDatesMillis": allExpirationsMillis,
        @"allPurchaseDates": allPurchases,
        @"allPurchaseDatesMillis": allPurchasesMillis,
        @"originalApplicationVersion": self.originalApplicationVersion ?: NSNull.null,
        @"originalPurchaseDate": [self formattedAsISO8601OrNull:self.originalPurchaseDate],
        @"originalPurchaseDateMillis": [self millisecondsSince1970OrNull:self.originalPurchaseDate],
        @"managementURL": managementURLorNull,
        @"nonSubscriptionTransactions": nonSubscriptionTransactionsArray
    };
}

- (NSObject *)millisecondsSince1970OrNull:(nullable NSDate *)date {
    if (date) {
        return @(date.rc_millisecondsSince1970AsDouble);
    } else {
        return NSNull.null;
    }
}

- (NSObject *)formattedAsISO8601OrNull:(nullable NSDate *)date {
    if (date) {
        return date.rc_formattedAsISO8601;
    } else {
        return NSNull.null;
    }
}

@end
