//
//  RCPurchases+HybridAdditionsAPITest.m
//  ObjCAPITester
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;
@import RevenueCat;

NS_ASSUME_NONNULL_BEGIN

@interface RCPurchasesHybridAdditionsAPITest: NSObject

@end

@implementation RCPurchasesHybridAdditionsAPITest
- (void)testAPI {
    RCPurchases *purchases __unused = [RCPurchases configureWithAPIKey:@""
                                                             appUserID:@""
                                                          observerMode:NO
                                                 userDefaultsSuiteName:nil
                                                        platformFlavor:nil
                                                 platformFlavorVersion:@""
                                                     dangerousSettings:nil];
    // This method will be removed, and instead we'll call `setPushTokenString` directly
    // on Purchases
//    [purchases _setPushTokenString:@""];

    // this method will be removed in favor of the one that passes the
    // userDefaults as String
//    [RCPurchases configureWithAPIKey:@""
//                           appUserID:@""
//                        observerMode:NO
//                        userDefaults:NSUserDefaults.standardUserDefaults
//                      platformFlavor:nil
//               platformFlavorVersion:@""
//                   dangerousSettings:nil];
}

@end

NS_ASSUME_NONNULL_END
