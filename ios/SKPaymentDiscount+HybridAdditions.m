//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "SKPaymentDiscount+HybridAdditions.h"

@implementation SKPaymentDiscount (RCPurchases)

- (NSDictionary *)dictionary
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:@{
                        @"identifier": self.identifier,
                        @"keyIdentifier": self.keyIdentifier,
                        @"nonce": self.nonce.UUIDString,
                        @"signature": self.signature,
                        @"timestamp": self.timestamp,
                        }];
    
    return d;
}

@end
