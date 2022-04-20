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
    [RCCommonFunctionality setAttributes:@{}];
    [RCCommonFunctionality setEmail:@""];
    [RCCommonFunctionality setEmail:nil];
    [RCCommonFunctionality setPhoneNumber:@""];
    [RCCommonFunctionality setPhoneNumber:nil];
    [RCCommonFunctionality setDisplayName:@""];
    [RCCommonFunctionality setDisplayName:nil];
    [RCCommonFunctionality setPushToken:@""];
    [RCCommonFunctionality setPushToken:nil];
    [RCCommonFunctionality collectDeviceIdentifiers];
    [RCCommonFunctionality setAdjustID:@""];
    [RCCommonFunctionality setAdjustID:nil];
    [RCCommonFunctionality setAppsflyerID:@""];
    [RCCommonFunctionality setAppsflyerID:nil];
    [RCCommonFunctionality setFBAnonymousID:@""];
    [RCCommonFunctionality setFBAnonymousID:nil];
    [RCCommonFunctionality setMparticleID:@""];
    [RCCommonFunctionality setMparticleID:nil];
    [RCCommonFunctionality setOnesignalID:@""];
    [RCCommonFunctionality setOnesignalID:nil];
    [RCCommonFunctionality setAirshipChannelID:@""];
    [RCCommonFunctionality setAirshipChannelID:nil];
    [RCCommonFunctionality setMediaSource:@""];
    [RCCommonFunctionality setMediaSource:nil];
    [RCCommonFunctionality setCampaign:@""];
    [RCCommonFunctionality setCampaign:nil];
    [RCCommonFunctionality setAdGroup:@""];
    [RCCommonFunctionality setAdGroup:nil];
    [RCCommonFunctionality setAd:@""];
    [RCCommonFunctionality setAd:nil];
    [RCCommonFunctionality setKeyword:@""];
    [RCCommonFunctionality setKeyword:nil];
    [RCCommonFunctionality setCreative:@""];
    [RCCommonFunctionality setCreative:nil];
}

@end

NS_ASSUME_NONNULL_END
