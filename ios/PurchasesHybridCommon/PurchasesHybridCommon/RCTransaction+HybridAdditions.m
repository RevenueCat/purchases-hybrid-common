//
//  RCTransaction+HybridAdditions.m
//  PurchasesHybridCommon
//
//  Created by César de la Vega  on 9/11/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

#import "RCTransaction+HybridAdditions.h"
#import "NSDate+HybridAdditions.h"

@implementation RCTransaction (RCPurchases)

- (NSDictionary *)dictionary
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{
        @"revenueCatId": self.revenueCatId,
        @"productId": self.productId,
        @"purchaseDateMillis": @(self.purchaseDate.rc_millisecondsSince1970AsDouble),
        @"purchaseDate": self.purchaseDate.rc_formattedAsISO8601
    }];
    
    return d;
}

@end
