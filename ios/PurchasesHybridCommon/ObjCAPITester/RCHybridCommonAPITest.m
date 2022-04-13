//
//  RCHybridCommonAPITest.m
//  RCHybridCommonAPITest
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;
@import PurchasesHybridCommonSwift;

NS_ASSUME_NONNULL_BEGIN
@interface RCHybridCommonAPITest: NSObject
@end


@implementation RCHybridCommonAPITest
- (void)testAPI {
    NSString *proxyURL = [RCCommonFunctionality proxyURLString];
    BOOL simulatesAskToBuyInSandbox = [RCCommonFunctionality simulatesAskToBuyInSandbox];

    [RCCommonFunctionality configure];
    [RCCommonFunctionality setAllowSharingStoreAccount:@NO];
    [RCCommonFunctionality addAttributionData:@{} network:@1 networkUserId:@"asdfg"];
    
    [RCCommonFunctionality getProductInfo:@[]
                           completionBlock:^(NSArray<NSDictionary *> * _Nonnull) {
    }];

    [RCCommonFunctionality restoreTransactionsWithCompletionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];

     [RCCommonFunctionality syncPurchasesWithCompletionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];

    [RCCommonFunctionality appUserID];
    [RCCommonFunctionality logInWithAppUserID:@""
                              completionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];

    [RCCommonFunctionality logOutWithCompletionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];

    [RCCommonFunctionality createAlias:@""
                       completionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];
    [RCCommonFunctionality identify:@""
                    completionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];

    [RCCommonFunctionality resetWithCompletionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];

    [RCCommonFunctionality setDebugLogsEnabled:@NO];
    [RCCommonFunctionality getPurchaserInfoWithCompletionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];

    [RCCommonFunctionality setAutomaticAppleSearchAdsAttributionCollection:@YES];
    [RCCommonFunctionality getOfferingsWithCompletionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];
    BOOL isAnonymous = RCCommonFunctionality.isAnonymous;


    [RCCommonFunctionality purchaseProduct:@""
                   signedDiscountTimestamp:@""
                           completionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];

     [RCCommonFunctionality purchasePackage:@""
                                   offering:@""
                    signedDiscountTimestamp:@""
                            completionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
     }];

    [RCCommonFunctionality makeDeferredPurchase:^(RCPurchaseCompletedBlock _Nonnull) {
    } completionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
    }];

    [RCCommonFunctionality setFinishTransactions:@NO];
    [RCCommonFunctionality checkTrialOrIntroductoryPriceEligibility:@"" completionBlock:^(NSDictionary<NSString *,RCIntroEligibility *> * _Nonnull) {
    }];
     [RCCommonFunctionality paymentDiscountForProductIdentifier:@""
                                                       discount:@"" completionBlock:^(NSDictionary * _Nullable, RCErrorContainer * _Nullable) {
     }];

    [RCCommonFunctionality presentCodeRedemptionSheet];
    [RCCommonFunctionality invalidatePurchaserInfoCache];
    [RCCommonFunctionality canMakePaymentsWithFeatures:@[]];
}

- (void)testSubscriberAttributes {
    [RCCommonFunctionality setAttributes:@{}];
    [RCCommonFunctionality setEmail:@""];
    [RCCommonFunctionality setPhoneNumber:@""];
    [RCCommonFunctionality setDisplayName:@""];
    [RCCommonFunctionality setPushToken:@""];
    [RCCommonFunctionality collectDeviceIdentifiers];
    [RCCommonFunctionality setAdjustID:@""];
    [RCCommonFunctionality setAppsflyerID:@""];
    [RCCommonFunctionality setFBAnonymousID:@""];
    [RCCommonFunctionality setMparticleID:@""];
    [RCCommonFunctionality setOnesignalID:@""];
    [RCCommonFunctionality setAirshipChannelID:@""];
    [RCCommonFunctionality setMediaSource:@""];
    [RCCommonFunctionality setCampaign:@""];
    [RCCommonFunctionality setAdGroup:@""];
    [RCCommonFunctionality setAd:@""];
    [RCCommonFunctionality setKeyword:@""];
    [RCCommonFunctionality setCreative:@""];
}

@end

NS_ASSUME_NONNULL_END
