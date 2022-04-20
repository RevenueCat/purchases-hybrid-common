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
@import Purchases;

NS_ASSUME_NONNULL_BEGIN
@interface RCCommonFunctionalityAPITest: NSObject
@end


@implementation RCCommonFunctionalityAPITest
- (void)testAPI {
    NSString *proxyURL __unused = [RCCommonFunctionality proxyURLString];
    BOOL simulatesAskToBuyInSandbox __unused = [RCCommonFunctionality simulatesAskToBuyInSandbox];

    [RCCommonFunctionality configure];
    // should issue deprecated warning
    [RCCommonFunctionality setAllowSharingStoreAccount:NO];

    // should issue deprecated warning
    [RCCommonFunctionality addAttributionData:@{} network:1 networkUserId:@"asdfg"];
    
    [RCCommonFunctionality getProductInfo:@[]
                          completionBlock:^(NSArray<NSDictionary *> * _Nonnull products) {
    }];

    [RCCommonFunctionality restoreTransactionsWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                                    RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality syncPurchasesWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                              RCErrorContainer * _Nullable error) {
    }];

    NSString *appUserID __unused = [RCCommonFunctionality appUserID];
    [RCCommonFunctionality logInWithAppUserID:@""
                              completionBlock:^(NSDictionary * _Nullable customerInfo,
                                                RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality logOutWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                       RCErrorContainer * _Nullable error) {
    }];

    // should issue deprecated warning
    [RCCommonFunctionality createAlias:@""
                       completionBlock:^(NSDictionary * _Nullable customerInfo,
                                         RCErrorContainer * _Nullable error) {
    }];

    // should issue deprecated warning
    [RCCommonFunctionality identify:@""
                    completionBlock:^(NSDictionary * _Nullable customerInfo,
                                      RCErrorContainer * _Nullable error) {
    }];

    // should issue deprecated warning
    [RCCommonFunctionality resetWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                      RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality setDebugLogsEnabled:NO];
    [RCCommonFunctionality getPurchaserInfoWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                                 RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality setAutomaticAppleSearchAdsAttributionCollection:YES];
    [RCCommonFunctionality getOfferingsWithCompletionBlock:^(NSDictionary * _Nullable offerings,
                                                             RCErrorContainer * _Nullable error) {
    }];
    BOOL isAnonymous __unused = RCCommonFunctionality.isAnonymous;

    [RCCommonFunctionality purchaseProduct:@""
                   signedDiscountTimestamp:@""
                           completionBlock:^(NSDictionary * _Nullable customerInfo,
                                             RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality purchasePackage:@""
                                  offering:@""
                   signedDiscountTimestamp:@""
                           completionBlock:^(NSDictionary * _Nullable customerInfo,
                                             RCErrorContainer * _Nullable error) {
    }];


    [RCCommonFunctionality makeDeferredPurchase:^(RCPurchaseCompletedBlock _Nonnull purchaseCompleted) {
    }
                                completionBlock:^(NSDictionary * _Nullable customerInfo,
                                                  RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality setFinishTransactions:NO];
    [RCCommonFunctionality checkTrialOrIntroductoryPriceEligibility:@[@""]
                                                    completionBlock:^(NSDictionary<NSString *, NSObject *>
                                                                      * _Nonnull eligibilities) {
    }];
    [RCCommonFunctionality paymentDiscountForProductIdentifier:@""
                                                      discount:@""
                                               completionBlock:^(NSDictionary * _Nullable discount,
                                                                 RCErrorContainer * _Nullable error) {
    }];

    if (@available(iOS 14.0, *)) {
        [RCCommonFunctionality presentCodeRedemptionSheet];
    }
    [RCCommonFunctionality invalidatePurchaserInfoCache];
    BOOL canMakePayments __unused = [RCCommonFunctionality canMakePaymentsWithFeatures:@[]];
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
