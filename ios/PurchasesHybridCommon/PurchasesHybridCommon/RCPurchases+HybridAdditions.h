//
// Created by RevenueCat on 3/19/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

#import <Foundation/Foundation.h>
@import RevenueCat;

NS_ASSUME_NONNULL_BEGIN

// JOSH: This is here because RCDangerousSettings is not in v4
@interface RCDangerousSettings: NSObject
@end

@interface RCPurchases (HybridAdditions)

- (void)_setPushTokenString:(nullable NSString *)pushToken;

+ (instancetype)configureWithAPIKey:(NSString *)APIKey
                          appUserID:(nullable NSString *)appUserID
                       observerMode:(BOOL)observerMode
              userDefaultsSuiteName:(nullable NSString *)userDefaultsSuiteName
                     platformFlavor:(nullable NSString *)platformFlavor
              platformFlavorVersion:(nullable NSString *)platformFlavorVersion
                  dangerousSettings:(nullable RCDangerousSettings *)dangerousSettings;

+ (instancetype)configureWithAPIKey:(NSString *)APIKey
                          appUserID:(nullable NSString *)appUserID
                       observerMode:(BOOL)observerMode
                       userDefaults:(nullable NSUserDefaults *)userDefaults
                     platformFlavor:(nullable NSString *)platformFlavor
              platformFlavorVersion:(nullable NSString *)platformFlavorVersion
                  dangerousSettings:(nullable RCDangerousSettings *)dangerousSettings;

@end


NS_ASSUME_NONNULL_END
