//
//  RCHybridPurchaseLogicBridgeAPITest.m
//  ObjCAPITester
//
//  Created by Rick van der Linden.
//  Copyright © 2026 RevenueCat. All rights reserved.
//

@import Foundation;
@import PurchasesHybridCommonUI;

NS_ASSUME_NONNULL_BEGIN

@interface RCHybridPurchaseLogicBridgeAPITest : NSObject

@end

@implementation RCHybridPurchaseLogicBridgeAPITest

- (void)testAPI {
    if (@available(iOS 15.0, *)) {
        HybridPurchaseLogicBridge *bridge = [[HybridPurchaseLogicBridge alloc]
            initOnPerformPurchase:^(NSDictionary<NSString *, id> *eventData) {}
                 onPerformRestore:^(NSDictionary<NSString *, id> *eventData) {}];

        __unused NSString *requestIdKey = HybridPurchaseLogicBridge.eventKeyRequestId;
        __unused NSString *packageKey = HybridPurchaseLogicBridge.eventKeyPackageBeingPurchased;
        __unused NSString *success = HybridPurchaseLogicBridge.resultSuccess;
        __unused NSString *cancellation = HybridPurchaseLogicBridge.resultCancellation;
        __unused NSString *error = HybridPurchaseLogicBridge.resultError;

        [HybridPurchaseLogicBridge resolveResultWithRequestId:@"id" resultString:HybridPurchaseLogicBridge.resultSuccess];
        [HybridPurchaseLogicBridge resolveResultWithRequestId:@"id" resultString:HybridPurchaseLogicBridge.resultError errorMessage:@"msg"];

        [bridge cancelPending];
    }
}

@end

NS_ASSUME_NONNULL_END
