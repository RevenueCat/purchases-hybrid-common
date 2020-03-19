//
// Created by Andrés Boedo on 3/19/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

#import "RCPurchases+HybridAdditions.h"
#import "RCPurchases+SubscriberAttributes.h"

NS_ASSUME_NONNULL_BEGIN


@interface RCPurchases (HybridAdditions)
@end




@implementation RCPurchases (HybridAdditions)

- (void)setPushTokenString:(nullable NSString *)pushToken {
    [self _setPushTokenString:pushToken];
}

@end

NS_ASSUME_NONNULL_END
