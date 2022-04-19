//
//  RCPurchases+HybridAdditionsAPITest.m
//  ObjCAPITester
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;
@import PurchasesHybridCommonSwift;

NS_ASSUME_NONNULL_BEGIN

@interface RCPurchasesHybridAdditionsAPITest: NSObject

@end

@implementation RCPurchasesHybridAdditionsAPITest
- (void)testAPI {
    RCPurchases *purchases = [RCPurchases configureWithAPIKey:@""
                                                    appUserID:@""
                                                 observerMode:NO
                                        userDefaultsSuiteName:nil
                                               platformFlavor:nil
                                        platformFlavorVersion:@""
                                            dangerousSettings:nil];
    [purchases _setPushTokenString:@""];
    
    [RCPurchases configureWithAPIKey:@""
                           appUserID:@""
                        observerMode:NO
                        userDefaults:NSUserDefaults.standardUserDefaults
                      platformFlavor:nil
               platformFlavorVersion:@""
                   dangerousSettings:nil];
}

@end

NS_ASSUME_NONNULL_END
