//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "RCOfferings+HybridAdditions.h"
@import PurchasesHybridCommonSwift;

@implementation RCOfferings (HybridAdditions)

- (NSDictionary *)dictionary
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary new];
    NSMutableDictionary *all = [NSMutableDictionary new];

    for (NSString *offeringId in self.all) {
        RCOffering *offering = self.all[offeringId];
        all[offeringId] = offering.dictionary;
    }

    jsonDict[@"all"] = [NSDictionary dictionaryWithDictionary:all];
    jsonDict[@"current"] = self.current.dictionary;

    return [NSDictionary dictionaryWithDictionary:jsonDict];
}

@end
