//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import <Purchases/Purchases.h>

NS_ASSUME_NONNULL_BEGIN

@class RCErrorContainer;

typedef void (^RCHybridResponseBlock)(NSDictionary * _Nullable, RCErrorContainer * _Nullable);


@interface RCCommonFunctionality : NSObject

@property (class, nonatomic, nullable, copy) NSString *proxyURLString;

@property (class, nonatomic, assign) BOOL simulatesAskToBuyInSandbox;

+ (void)configure;

+ (void)setAllowSharingStoreAccount:(BOOL)allowSharingStoreAccount
__attribute((deprecated("Configure behavior through the RevenueCat dashboard instead.")));

+ (void)addAttributionData:(NSDictionary *)data
                   network:(NSInteger)network
             networkUserId:(NSString *)networkUserId
__attribute((deprecated("Use the set<NetworkId> functions instead.")));

+ (void)getProductInfo:(NSArray *)products completionBlock:(void (^)(NSArray<NSDictionary *> *))completion;

+ (void)restoreTransactionsWithCompletionBlock:(RCHybridResponseBlock)completion;

+ (void)syncPurchasesWithCompletionBlock:(nullable RCHybridResponseBlock)completion;

+ (NSString *)appUserID;

+ (void)logInWithAppUserID:(NSString *)appUserId completionBlock:(RCHybridResponseBlock)completion;

+ (void)logOutWithCompletionBlock:(RCHybridResponseBlock)completion;

+ (void)createAlias:(nullable NSString *)newAppUserId completionBlock:(RCHybridResponseBlock)completion 
__attribute((deprecated("Use logIn instead.")));

+ (void)identify:(NSString *)appUserId
 completionBlock:(RCHybridResponseBlock)completion
__attribute((deprecated("Use logIn instead.")));

+ (void)resetWithCompletionBlock:(RCHybridResponseBlock)completion
__attribute((deprecated("Use logOut instead.")));

+ (void)setDebugLogsEnabled:(BOOL)enabled;

+ (void)getPurchaserInfoWithCompletionBlock:(RCHybridResponseBlock)completion;

+ (void)setAutomaticAppleSearchAdsAttributionCollection:(BOOL)enabled;

+ (void)getOfferingsWithCompletionBlock:(RCHybridResponseBlock)completion;

+ (BOOL)isAnonymous;

+ (void)purchaseProduct:(NSString *)productIdentifier
signedDiscountTimestamp:(nullable NSString *)discountTimestamp
        completionBlock:(RCHybridResponseBlock)completion;

+ (void)purchasePackage:(NSString *)packageIdentifier
               offering:(NSString *)offeringIdentifier
signedDiscountTimestamp:(nullable NSString *)discountTimestamp
        completionBlock:(RCHybridResponseBlock)completion;

+ (void)makeDeferredPurchase:(RCDeferredPromotionalPurchaseBlock)deferredPurchase
             completionBlock:(RCHybridResponseBlock)completion;

+ (void)setFinishTransactions:(BOOL)finishTransactions;

+ (void)checkTrialOrIntroductoryPriceEligibility:(nonnull NSArray<NSString *> *)productIdentifiers
                                 completionBlock:(RCReceiveIntroEligibilityBlock)completion;

+ (void)paymentDiscountForProductIdentifier:(NSString *)productIdentifier
                                   discount:(nullable NSString *)discountIdentifier
                            completionBlock:(RCHybridResponseBlock)completion;

+ (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0)) API_UNAVAILABLE(tvos, macos, watchos);

+ (void)invalidatePurchaserInfoCache;

+ (void)setAttributes:(NSDictionary<NSString *, NSString *> *)attributes;

+ (void)setEmail:(nullable NSString *)email;

+ (void)setPhoneNumber:(nullable NSString *)phoneNumber;

+ (void)setDisplayName:(nullable NSString *)displayName;

+ (void)setPushToken:(nullable NSString *)pushToken;

+ (void)collectDeviceIdentifiers;

+ (void)setAdjustID:(nullable NSString *)adjustID;

+ (void)setAppsflyerID:(nullable NSString *)appsflyerID;

+ (void)setFBAnonymousID:(nullable NSString *)fbAnonymousID;

+ (void)setMparticleID:(nullable NSString *)mparticleID;

+ (void)setOnesignalID:(nullable NSString *)onesignalID;

+ (void)setAirshipChannelID:(nullable NSString *)airshipChannelID;

+ (void)setMediaSource:(nullable NSString *)mediaSource;

+ (void)setCampaign:(nullable NSString *)campaign;

+ (void)setAdGroup:(nullable NSString *)adGroup;

+ (void)setAd:(nullable NSString *)ad;

+ (void)setKeyword:(nullable NSString *)keyword;

+ (void)setCreative:(nullable NSString *)creative;

+ (BOOL)canMakePaymentsWithFeatures:(NSArray<NSNumber *> *)features;

NS_ASSUME_NONNULL_END
@end
