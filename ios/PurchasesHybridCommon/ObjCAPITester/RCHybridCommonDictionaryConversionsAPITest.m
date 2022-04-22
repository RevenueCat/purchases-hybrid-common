//
//  RCHybridCommonDictionaryConversionsAPITest.m
//  ObjCAPITester
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;
@import RevenueCat;
@import StoreKit;

NS_ASSUME_NONNULL_BEGIN

@interface RCHybridCommonDictionaryConversionsAPITest: NSObject

@end

@implementation RCHybridCommonDictionaryConversionsAPITest

- (void)testAPI {
    NSDictionary *dict;
    RCEntitlementInfo *entitlementInfo;
    RCEntitlementInfos *entitlementInfos;
    RCOffering *offering;
    RCOfferings *offerings;
    RCPackage *package;
    RCCustomerInfo *customerInfo;
    RCPromotionalOffer *promotionalOffer;
    dict = [entitlementInfo dictionary];
    dict = [entitlementInfos dictionary];
    dict = [offering dictionary];
    dict = [offerings dictionary];
    dict = [package dictionary:@""];
    dict = [customerInfo dictionary];
    if (@available(iOS 12.2, *)) {
        [promotionalOffer rc_dictionary];
    }
    SKProduct *product = [[SKProduct alloc] init];
    dict = [product rc_dictionary];
    NSString *string;
    if (@available(iOS 11.2, *)) {
        string = [SKProduct rc_normalizedSubscriptionPeriod:[[SKProductSubscriptionPeriod alloc] init]];
        string = [SKProduct rc_normalizedSubscriptionPeriodUnit:SKProductPeriodUnitDay];
        dict = [[[SKProductDiscount alloc] init] rc_dictionary];
    }

    RCStoreTransaction *transaction;
    dict = [transaction dictionary];

}

@end

NS_ASSUME_NONNULL_END
