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
        @"purchaseDateMillis": @(self.purchaseDate.timeIntervalSince1970),
        @"purchaseDate": self.purchaseDate.formattedAsISO8601
    }];
    
    return d;
}

@end
