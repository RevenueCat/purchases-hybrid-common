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
                                               purchasesAreCompletedBy:RCPurchasesAreCompletedByRevenueCat
                                                 userDefaultsSuiteName:nil
                                                        platformFlavor:nil
                                                 platformFlavorVersion:@""
                                                       storeKitVersion:@""
                                                     dangerousSettings:nil
                                  shouldShowInAppMessagesAutomatically:NO
                                                      verificationMode:@""
                                                    diagnosticsEnabled:YES
                            automaticDeviceIdentifierCollectionEnabled:YES
                                                       preferredLocale:nil];
    RCPurchases *purchases2 __unused = [RCPurchases configureWithAPIKey:@""
                                                             appUserID:@""
                                               purchasesAreCompletedBy:RCPurchasesAreCompletedByRevenueCat
                                                 userDefaultsSuiteName:nil
                                                        platformFlavor:nil
                                                 platformFlavorVersion:@""
                                                       storeKitVersion:@""
                                                     dangerousSettings:nil
                                  shouldShowInAppMessagesAutomatically:NO
                                                      verificationMode:@""
                                                    diagnosticsEnabled:YES
                            automaticDeviceIdentifierCollectionEnabled:YES];
    RCPurchases *purchases3 __unused = [RCPurchases configureWithAPIKey:@""
                                                              appUserID:@""
                                                purchasesAreCompletedBy:RCPurchasesAreCompletedByRevenueCat
                                                  userDefaultsSuiteName:nil
                                                         platformFlavor:nil
                                                  platformFlavorVersion:@""
                                                        storeKitVersion:@""
                                                      dangerousSettings:nil
                                   shouldShowInAppMessagesAutomatically:NO
                                                       verificationMode:@""
                                                     diagnosticsEnabled:YES];
    RCPurchases *purchases4 __unused = [RCPurchases configureWithAPIKey:@""
                                                              appUserID:@""
                                                purchasesAreCompletedBy:RCPurchasesAreCompletedByRevenueCat
                                                  userDefaultsSuiteName:nil
                                                         platformFlavor:nil
                                                  platformFlavorVersion:@""
                                                        storeKitVersion:@""
                                                      dangerousSettings:nil
                                   shouldShowInAppMessagesAutomatically:NO
                                                       verificationMode:@""];
    RCPurchases *purchases5 __unused = [RCPurchases configureWithAPIKey:@""
                                                              appUserID:@""
                                                purchasesAreCompletedBy:RCPurchasesAreCompletedByRevenueCat
                                                  userDefaultsSuiteName:nil
                                                         platformFlavor:nil
                                                  platformFlavorVersion:@""
                                                        storeKitVersion:@""
                                                      dangerousSettings:nil
                                   shouldShowInAppMessagesAutomatically:NO];
}

@end

NS_ASSUME_NONNULL_END
