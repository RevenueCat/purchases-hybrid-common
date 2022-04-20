//
//  RCCommonFunctionalityAPITest.m
//  RCCommonFunctionalityAPITest
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;
@import PurchasesHybridCommonSwift;

NS_ASSUME_NONNULL_BEGIN
@interface RCCommonFunctionalityAPITest: NSObject
@end


@implementation RCCommonFunctionalityAPITest
- (void)testAPI {
    NSString *proxyURL __unused = [RCCommonFunctionality2 proxyURLString];
    BOOL simulatesAskToBuyInSandbox __unused = [RCCommonFunctionality2 simulatesAskToBuyInSandbox];

    [RCCommonFunctionality2 configure];
    // should issue deprecated warning
    [RCCommonFunctionality2 setAllowSharingStoreAccount:NO];

    // should issue deprecated warning
    [RCCommonFunctionality2 addAttributionData:@{} network:1 networkUserId:@"asdfg"];
    
    [RCCommonFunctionality2 getProductInfo:@[]
                           completionBlock:^(NSArray<NSDictionary *> * _Nonnull products) {
    }];

    [RCCommonFunctionality2 restoreTransactionsWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                                     RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality2 syncPurchasesWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                               RCErrorContainer * _Nullable error) {
    }];

    NSString *appUserID __unused = [RCCommonFunctionality2 appUserID];
    [RCCommonFunctionality2 logInWithAppUserID:@""
                               completionBlock:^(NSDictionary * _Nullable customerInfo,
                                                 RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality2 logOutWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                        RCErrorContainer * _Nullable error) {
    }];

    // should issue deprecated warning
    [RCCommonFunctionality2 createAlias:@""
                        completionBlock:^(NSDictionary * _Nullable customerInfo,
                                          RCErrorContainer * _Nullable error) {
    }];

    // should issue deprecated warning
    [RCCommonFunctionality2 identify:@""
                     completionBlock:^(NSDictionary * _Nullable customerInfo,
                                       RCErrorContainer * _Nullable error) {
    }];

    // should issue deprecated warning
    [RCCommonFunctionality2 resetWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                       RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality2 setDebugLogsEnabled:NO];
    [RCCommonFunctionality2 getPurchaserInfoWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                                  RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality2 setAutomaticAppleSearchAdsAttributionCollection:YES];
    [RCCommonFunctionality2 getOfferingsWithCompletionBlock:^(NSDictionary * _Nullable offerings,
                                                              RCErrorContainer * _Nullable error) {
    }];
    BOOL isAnonymous __unused = RCCommonFunctionality2.isAnonymous;

    [RCCommonFunctionality2 purchaseProduct:@""
                    signedDiscountTimestamp:@""
                            completionBlock:^(NSDictionary * _Nullable customerInfo,
                                              RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality2 purchasePackage:@""
                                   offering:@""
                    signedDiscountTimestamp:@""
                            completionBlock:^(NSDictionary * _Nullable customerInfo,
                                              RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality2 makeDeferredPurchase:^(RCPurchaseCompletedBlock _Nonnull purchaseCompleted) {
    }
                                 completionBlock:^(NSDictionary * _Nullable customerInfo,
                                                   RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality2 setFinishTransactions:NO];
    [RCCommonFunctionality2 checkTrialOrIntroductoryPriceEligibility:@[@""]
                                                     completionBlock:^(NSDictionary<NSString *, NSObject *>
                                                                       * _Nonnull eligibilities) {
    }];
    [RCCommonFunctionality2 paymentDiscountForProductIdentifier:@""
                                                       discount:@""
                                                completionBlock:^(NSDictionary * _Nullable discount,
                                                                  RCErrorContainer * _Nullable error) {
    }];

    if (@available(iOS 14.0, *)) {
        [RCCommonFunctionality2 presentCodeRedemptionSheet];
    }
    [RCCommonFunctionality2 invalidatePurchaserInfoCache];
    BOOL canMakePayments __unused = [RCCommonFunctionality2 canMakePaymentsWithFeatures:@[]];
}

- (void)testSubscriberAttributes {
    [RCCommonFunctionality2 setAttributes:@{}];
    [RCCommonFunctionality2 setEmail:@""];
    [RCCommonFunctionality2 setEmail:nil];
    [RCCommonFunctionality2 setPhoneNumber:@""];
    [RCCommonFunctionality2 setPhoneNumber:nil];
    [RCCommonFunctionality2 setDisplayName:@""];
    [RCCommonFunctionality2 setDisplayName:nil];
    [RCCommonFunctionality2 setPushToken:@""];
    [RCCommonFunctionality2 setPushToken:nil];
    [RCCommonFunctionality2 collectDeviceIdentifiers];
    [RCCommonFunctionality2 setAdjustID:@""];
    [RCCommonFunctionality2 setAdjustID:nil];
    [RCCommonFunctionality2 setAppsflyerID:@""];
    [RCCommonFunctionality2 setAppsflyerID:nil];
    [RCCommonFunctionality2 setFBAnonymousID:@""];
    [RCCommonFunctionality2 setFBAnonymousID:nil];
    [RCCommonFunctionality2 setMparticleID:@""];
    [RCCommonFunctionality2 setMparticleID:nil];
    [RCCommonFunctionality2 setOnesignalID:@""];
    [RCCommonFunctionality2 setOnesignalID:nil];
    [RCCommonFunctionality2 setAirshipChannelID:@""];
    [RCCommonFunctionality2 setAirshipChannelID:nil];
    [RCCommonFunctionality2 setMediaSource:@""];
    [RCCommonFunctionality2 setMediaSource:nil];
    [RCCommonFunctionality2 setCampaign:@""];
    [RCCommonFunctionality2 setCampaign:nil];
    [RCCommonFunctionality2 setAdGroup:@""];
    [RCCommonFunctionality2 setAdGroup:nil];
    [RCCommonFunctionality2 setAd:@""];
    [RCCommonFunctionality2 setAd:nil];
    [RCCommonFunctionality2 setKeyword:@""];
    [RCCommonFunctionality2 setKeyword:nil];
    [RCCommonFunctionality2 setCreative:@""];
    [RCCommonFunctionality2 setCreative:nil];
}

@end

NS_ASSUME_NONNULL_END
