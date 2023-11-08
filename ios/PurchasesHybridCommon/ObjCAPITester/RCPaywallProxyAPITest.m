//
//  RCPaywallProxyAPITest.m
//  ObjCAPITester
//
//  Created by Nacho Soto on 11/7/23.
//  Copyright © 2023 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;

NS_ASSUME_NONNULL_BEGIN

@interface RCPaywallProxyAPITest : NSObject

@end

@implementation RCPaywallProxyAPITest

- (void)testAPI {
    if (@available(iOS 15.0, *)) {
        [PaywallProxy presentPaywall];
        [PaywallProxy presentPaywallIfNeededWithRequiredEntitlementIdentifier:@""];
    }
}

@end

NS_ASSUME_NONNULL_END
