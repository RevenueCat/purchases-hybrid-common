//
// Created by RevenueCat.
// Copyright (c) 2020 Purchases. All rights reserved.
//

#import "RCPurchases+HybridAdditions.h"
#import <Purchases/Purchases.h>


NS_ASSUME_NONNULL_BEGIN


@implementation RCPurchases (HybridAdditions)

+ (instancetype)configureWithAPIKey:(NSString *)APIKey
                          appUserID:(nullable NSString *)appUserID
                       observerMode:(BOOL)observerMode
              userDefaultsSuiteName:(nullable NSString *)userDefaultsSuiteName
                     platformFlavor:(nullable NSString *)platformFlavor
              platformFlavorVersion:(nullable NSString *)platformFlavorVersion {
    NSUserDefaults *userDefaults;
    if (userDefaultsSuiteName) {
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:userDefaultsSuiteName];
        NSAssert(userDefaults,
                 @"Could not create an instance of NSUserDefaults with suite name %@", userDefaultsSuiteName);
    }
    return [self configureWithAPIKey:APIKey
                           appUserID:appUserID
                        observerMode:observerMode
                        userDefaults:userDefaults
                      platformFlavor:platformFlavor
               platformFlavorVersion:platformFlavorVersion];
}

+ (void)setProxyURLString:(nullable NSString *)proxyURLString {
    NSURL *proxyURL = [NSURL URLWithString:proxyURLString];
    if (proxyURLString != nil && proxyURL == nil) {
        NSAssert(false, @"couldn't parse the proxy URL string \"%@\" into a valid URL!", proxyURLString);
    }
    self.proxyURL = [NSURL URLWithString:proxyURLString];
}

+ (nullable NSString *)proxyURLString {
    return self.proxyURL.absoluteString;
}

@end


NS_ASSUME_NONNULL_END
