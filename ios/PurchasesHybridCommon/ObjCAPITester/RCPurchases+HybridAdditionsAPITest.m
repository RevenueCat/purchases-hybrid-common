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
                                              usesStoreKit2IfAvailable:YES
                                                     dangerousSettings:nil
                                  shouldShowInAppMessagesAutomatically:NO
                                                      verificationMode:@""];
    RCPurchases *purchases2 __unused = [RCPurchases configureWithAPIKey:@""
                                                              appUserID:@""
                                                           observerMode:NO
                                                  userDefaultsSuiteName:nil
                                                         platformFlavor:nil
                                                  platformFlavorVersion:@""
                                               usesStoreKit2IfAvailable:YES
                                                      dangerousSettings:nil
                                   shouldShowInAppMessagesAutomatically:NO];
    NSString *version __unused = [RCPurchases hybridCommonVersion];
}

@end

NS_ASSUME_NONNULL_END
