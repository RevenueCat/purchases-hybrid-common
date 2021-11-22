//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "RCEntitlementInfo+HybridAdditions.h"
#import "SKProduct+HybridAdditions.h"
#import "NSDate+HybridAdditions.h"

@implementation RCEntitlementInfo (HybridAdditions)

- (NSDictionary *)dictionary
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary new];
    jsonDict[@"identifier"] = self.identifier;
    jsonDict[@"isActive"] = @(self.isActive);
    jsonDict[@"willRenew"] = @(self.willRenew);

    switch (self.periodType) {
        case RCIntro:
            jsonDict[@"periodType"] = @"INTRO";
            break;
        case RCNormal:
            jsonDict[@"periodType"] = @"NORMAL";
            break;
        case RCTrial:
            jsonDict[@"periodType"] = @"TRIAL";
            break;
    }

    jsonDict[@"latestPurchaseDate"] = self.latestPurchaseDate.rc_formattedAsISO8601;
    jsonDict[@"latestPurchaseDateMillis"] = @(self.latestPurchaseDate.rc_millisecondsSince1970AsDouble);
    jsonDict[@"originalPurchaseDate"] = self.originalPurchaseDate.rc_formattedAsISO8601;
    jsonDict[@"originalPurchaseDateMillis"] = @(self.originalPurchaseDate.rc_millisecondsSince1970AsDouble);
    jsonDict[@"expirationDate"] = self.expirationDate.rc_formattedAsISO8601 ?: [NSNull null];
    jsonDict[@"expirationDateMillis"] = self.expirationDate
                                        ? @(self.expirationDate.rc_millisecondsSince1970AsDouble)
                                        : [NSNull null];

    switch (self.store) {
        case RCAppStore:
            jsonDict[@"store"] = @"APP_STORE";
            break;
        case RCMacAppStore:
            jsonDict[@"store"] = @"MAC_APP_STORE";
            break;
        case RCPlayStore:
            jsonDict[@"store"] = @"PLAY_STORE";
            break;
        case RCStripe:
            jsonDict[@"store"] = @"STRIPE";
            break;
        case RCPromotional:
            jsonDict[@"store"] = @"PROMOTIONAL";
            break;
        case RCUnknownStore:
            jsonDict[@"store"] = @"UNKNOWN_STORE";
            break;
    }
    
    jsonDict[@"productIdentifier"] = self.productIdentifier;
    jsonDict[@"isSandbox"] = @(self.isSandbox);
    jsonDict[@"unsubscribeDetectedAt"] = self.unsubscribeDetectedAt.rc_formattedAsISO8601 ?: [NSNull null];
    jsonDict[@"unsubscribeDetectedAtMillis"] = self.unsubscribeDetectedAt
                                               ? @(self.unsubscribeDetectedAt.rc_millisecondsSince1970AsDouble)
                                               : [NSNull null];
    jsonDict[@"billingIssueDetectedAt"] = self.billingIssueDetectedAt.rc_formattedAsISO8601 ?: [NSNull null];
    jsonDict[@"billingIssueDetectedAtMillis"] = self.billingIssueDetectedAt
                                                ? @(self.billingIssueDetectedAt.rc_millisecondsSince1970AsDouble)
                                                : [NSNull null];

    switch (self.ownershipType) {
        case RCPurchaseOwnershipTypeUnknown:
            jsonDict[@"ownershipType"] = @"UNKNOWN";
            break;
        case RCPurchaseOwnershipTypePurchased:
            jsonDict[@"ownershipType"] = @"PURCHASED";
            break;
        case RCPurchaseOwnershipTypeFamilyShared:
            jsonDict[@"ownershipType"] = @"FAMILY_SHARED";
            break;
    }
    
    return [NSDictionary dictionaryWithDictionary:jsonDict];
}

@end
