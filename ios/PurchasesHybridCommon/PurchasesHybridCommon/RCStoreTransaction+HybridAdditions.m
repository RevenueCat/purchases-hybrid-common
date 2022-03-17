//
//  RCStoreTransaction+HybridAdditions.m
//  PurchasesHybridCommon
//
//  Created by César de la Vega  on 9/11/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

#import "RCStoreTransaction+HybridAdditions.h"
#import "NSDate+HybridAdditions.h"

@implementation RCStoreTransaction (RCPurchases)

- (NSDictionary *)dictionary
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{
        // JOSH: is transactionIdentifier acutaly revenueCatId?????
        // JOSH: do we need to change these keys? Maddie: we dont HAVE to, it's all internal. but probably good to.
        @"revenueCatIdentifier": self.transactionIdentifier,
        @"productIdentifier": self.productIdentifier,
        @"purchaseDateMillis": @(self.purchaseDate.rc_millisecondsSince1970AsDouble),
        @"purchaseDate": self.purchaseDate.rc_formattedAsISO8601
    }];
    
    return d;
}

@end
