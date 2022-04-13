//
//  RCHybridCommonDictionaryConversionsAPITest.m
//  ObjCAPITester
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;
@import PurchasesHybridCommonSwift;

NS_ASSUME_NONNULL_BEGIN

@interface RCHybridCommonDictionaryConversionsAPITest: NSObject

@end

@implementation RCHybridCommonDictionaryConversionsAPITest

- (void)testAPI {
    NSDictionary *dict;
    dict = [[[RCEntitlementInfo alloc] init] dictionary];
    dict = [[[RCEntitlementInfos alloc] init] dictionary];
    dict = [[[RCOffering alloc] init] dictionary];
    dict = [[[RCOfferings alloc] init] dictionary];
    dict = [[[RCPackage alloc] init] dictionary:@""];
    dict = [[[RCPurchaserInfo alloc] init] dictionary];
    if (@available(iOS 12.2, *)) {
        [[[SKPaymentDiscount alloc] init] rc_dictionary];
    }
    SKProduct *product = [[SKProduct alloc] init];
    dict = [product rc_dictionary];
    NSString *string;
    if (@available(iOS 11.2, *)) {
        string = [SKProduct rc_normalizedSubscriptionPeriod:[[SKProductSubscriptionPeriod alloc] init]];
        string = [SKProduct rc_normalizedSubscriptionPeriodUnit:SKProductPeriodUnitDay];
        dict = [[[SKProductDiscount alloc] init] rc_dictionary];
    }

    RCTransaction *transaction;
    dict = [transaction dictionary];

}

@end

NS_ASSUME_NONNULL_END
