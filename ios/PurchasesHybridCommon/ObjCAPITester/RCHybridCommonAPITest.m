//
//  RCCommonFunctionalityAPITest.m
//  RCCommonFunctionalityAPITest
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;
@import RevenueCat;

NS_ASSUME_NONNULL_BEGIN
@interface RCCommonFunctionalityAPITest: NSObject
@end

@implementation RCCommonFunctionalityAPITest
- (void)testAPI {
    NSString *proxyURL __unused = [RCCommonFunctionality proxyURLString];
    BOOL simulatesAskToBuyInSandbox __unused = [RCCommonFunctionality simulatesAskToBuyInSandbox];


    [RCCommonFunctionality getProductInfo:@[]
                          completionBlock:^(NSArray<NSDictionary *> * _Nonnull products) {
    }];

    [RCCommonFunctionality restorePurchasesWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
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

    [RCCommonFunctionality setDebugLogsEnabled:NO];
    [RCCommonFunctionality setLogLevel:@"WARN"];
    [RCCommonFunctionality setLogHanderOnLogReceived:^(NSDictionary<NSString *,NSString *> * _Nonnull logDetails) {
    }];
    [RCCommonFunctionality getCustomerInfoWithCompletionBlock:^(NSDictionary * _Nullable customerInfo,
                                                                RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality getOfferingsWithCompletionBlock:^(NSDictionary * _Nullable offerings,
                                                             RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality getCurrentOfferingForPlacement:@"" completionBlock:^(NSDictionary<NSString *,id> * _Nullable offering, RCErrorContainer * _Nullable error) {

    }];

    [RCCommonFunctionality syncAttributesAndOfferingsIfNeededWithCompletionBlock:^(NSDictionary<NSString *,id> * _Nullable offerings, RCErrorContainer * _Nullable error) {

    }];

    BOOL isAnonymous __unused = RCCommonFunctionality.isAnonymous;
    NSString *version __unused = RCCommonFunctionality.hybridCommonVersion;

    [RCCommonFunctionality purchaseProduct:@""
                   signedDiscountTimestamp:@""
                           completionBlock:^(NSDictionary * _Nullable customerInfo,
                                             RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality purchasePackage:@""
                  presentedOfferingContext:@{}
                   signedDiscountTimestamp:@""
                           completionBlock:^(NSDictionary * _Nullable customerInfo,
                                             RCErrorContainer * _Nullable error) {
    }];

    // Win-Back Offers
    [RCCommonFunctionality eligibleWinBackOffersForProductIdentifier:@"" completionBlock:^(NSArray<NSDictionary *> * _Nullable offers, RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality purchaseProduct:@""
                            winBackOfferID:@""
                           completionBlock:^(NSDictionary * _Nullable customerInfo,
                                             RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality purchasePackage:@""
                  presentedOfferingContext:@{}
                            winBackOfferID:@""
                           completionBlock:^(NSDictionary * _Nullable customerInfo,
                                             RCErrorContainer * _Nullable error) {
    }];

    [RCCommonFunctionality makeDeferredPurchase:^(void (^ _Nonnull startDeferredPurchase)
                                                  (RCStoreTransaction * _Nullable storeTransaction,
                                                   RCCustomerInfo * _Nullable customerInfo,
                                                   NSError * _Nullable error,
                                                   BOOL userCancelled)) {

    }
                                completionBlock:^(NSDictionary<NSString *,id> * _Nullable customerInfo,
                                                  RCErrorContainer * _Nullable error) {

    }];

    [RCCommonFunctionality setPurchasesAreCompletedBy:RCPurchasesAreCompletedByRevenueCat];
    [RCCommonFunctionality checkTrialOrIntroductoryPriceEligibility:@[@""]
                                                    completionBlock:^(NSDictionary<NSString *, NSObject *>
                                                                      * _Nonnull eligibilities) {
    }];
    [RCCommonFunctionality promotionalOfferForProductIdentifier:@""
                                                       discount:@""
                                                completionBlock:^(NSDictionary * _Nullable discount,
                                                                  RCErrorContainer * _Nullable error) {
    }];

    if (@available(iOS 14.0, *)) {
        [RCCommonFunctionality presentCodeRedemptionSheet];
    }
    [RCCommonFunctionality invalidateCustomerInfoCache];
    BOOL canMakePayments __unused = [RCCommonFunctionality canMakePaymentsWithFeatures:@[]];

    if (@available(iOS 15.0, *)) {
        [RCCommonFunctionality beginRefundRequestProductId:@""
                                           completionBlock:^(RCErrorContainer * _Nullable error) {
        }];
        [RCCommonFunctionality beginRefundRequestEntitlementId:@""
                                               completionBlock:^(RCErrorContainer * _Nullable error) {
        }];
        [RCCommonFunctionality beginRefundRequestForActiveEntitlementCompletion:^(RCErrorContainer * _Nullable error) {
        }];
    }

    RCCustomerInfo *info;
    NSDictionary<NSString *, NSObject *> __unused *dictionary = [RCCommonFunctionality encodeCustomerInfo:info];
}

- (void)testDeprecatedAPI {
    [RCCommonFunctionality setAllowSharingStoreAccount:NO];
    
    if (@available(iOS 14.3, *)) {
        [RCCommonFunctionality enableAdServicesAttributionTokenCollection];
    }
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
    [RCCommonFunctionality setOnesignalUserID:@""];
    [RCCommonFunctionality setOnesignalUserID:nil];
    [RCCommonFunctionality setAirshipChannelID:@""];
    [RCCommonFunctionality setAirshipChannelID:nil];
    [RCCommonFunctionality setTenjinAnalyticsInstallationID:@""];
    [RCCommonFunctionality setTenjinAnalyticsInstallationID:nil];
    [RCCommonFunctionality setKochavaDeviceID:@""];
    [RCCommonFunctionality setKochavaDeviceID:nil];
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
