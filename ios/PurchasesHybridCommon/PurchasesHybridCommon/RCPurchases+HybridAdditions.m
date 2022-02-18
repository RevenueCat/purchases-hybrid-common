//
// Created by RevenueCat.
// Copyright (c) 2020 Purchases. All rights reserved.
//

#import "RCPurchases+HybridAdditions.h"
@import RevenueCat;


NS_ASSUME_NONNULL_BEGIN

// some of the methods declared in the header are privately implemented in RCPurchases.h in the main SDK.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation RCPurchases (HybridAdditions)

+ (instancetype)configureWithAPIKey:(NSString *)APIKey
                          appUserID:(nullable NSString *)appUserID
                       observerMode:(BOOL)observerMode
              userDefaultsSuiteName:(nullable NSString *)userDefaultsSuiteName
                     platformFlavor:(nullable NSString *)platformFlavor
              platformFlavorVersion:(nullable NSString *)platformFlavorVersion
                  dangerousSettings:(nullable RCDangerousSettings *)dangerousSettings {
    NSUserDefaults *userDefaults;
    if (userDefaultsSuiteName) {
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:userDefaultsSuiteName];
        NSAssert(userDefaults,
                 @"Could not create an instance of NSUserDefaults with suite name %@", userDefaultsSuiteName);
    }
    
    RCPlatformInfo *platformInfo = [[RCPlatformInfo alloc] initWithFlavor:platformFlavor version:platformFlavorVersion];
    [RCPurchases setPlatformInfo:platformInfo];
    
    return [self configureWithAPIKey:APIKey
                           appUserID:appUserID
                        observerMode:observerMode
                        userDefaults:userDefaults
             useStoreKit2IfAvailable:NO
                   dangerousSettings:dangerousSettings];
}
#pragma clang diagnostic pop

@end


NS_ASSUME_NONNULL_END
