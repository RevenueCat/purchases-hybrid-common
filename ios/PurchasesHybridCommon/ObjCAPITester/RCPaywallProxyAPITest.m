//
//  RCPaywallProxyAPITest.m
//  ObjCAPITester
//
//  Created by Nacho Soto on 11/7/23.
//  Copyright © 2023 RevenueCat. All rights reserved.
//

@import Foundation;
@import PurchasesHybridCommonUI;
@import RevenueCat;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface RCPaywallProxyAPITest : NSObject

@end

@implementation RCPaywallProxyAPITest

- (void)testAPI {
    if (@available(iOS 15.0, *)) {
        RCOffering *offering;

        PaywallProxy *proxy = [PaywallProxy new];
        [proxy presentPaywall];
        [proxy presentPaywallWithDisplayCloseButton:true];
        [proxy presentPaywallWithPaywallResultHandler:^(NSString *result) {}];
        [proxy presentPaywallWithDisplayCloseButton:true paywallResultHandler:^(NSString *result) {}];
        [proxy presentPaywallWithOffering:offering displayCloseButton:true paywallResultHandler:^(NSString *result) {}];
        [proxy presentPaywallWithOfferingIdentifier:@"offering" 
                                 displayCloseButton:true
                               paywallResultHandler:^(NSString *result) {}];
        [proxy presentPaywallWithOptions:[NSDictionary new] paywallResultHandler:^(NSString * _Nonnull result) {}];

        [proxy presentPaywallIfNeededWithRequiredEntitlementIdentifier:@""];
        [proxy presentPaywallIfNeededWithRequiredEntitlementIdentifier:@"" displayCloseButton:YES];
        [proxy presentPaywallIfNeededWithRequiredEntitlementIdentifier:@""
                                                  paywallResultHandler:^(NSString *result) {}];
        [proxy presentPaywallIfNeededWithRequiredEntitlementIdentifier:@""
                                                    displayCloseButton:true
                                                  paywallResultHandler:^(NSString *result) {}];
        [proxy presentPaywallIfNeededWithRequiredEntitlementIdentifier:@""
                                                    offeringIdentifier:@"offering"
                                                    displayCloseButton:true
                                                  paywallResultHandler:^(NSString *result) {}];
        [proxy presentPaywallIfNeededWithOptions:[NSDictionary new] paywallResultHandler:^(NSString * _Nonnull result) {
        }];

        NSString *customVariablesKey = PaywallOptionsKeys.customVariables;
        NSDictionary *optionsWithCustomVariables = @{
            PaywallOptionsKeys.customVariables: @{@"user_name": @"John"}
        };
        [proxy presentPaywallWithOptions:optionsWithCustomVariables paywallResultHandler:^(NSString * _Nonnull result) {}];

        __unused RCPaywallViewController *view1 = [proxy createPaywallView];
        __unused RCPaywallViewController *view2 = [proxy createPaywallViewWithOfferingIdentifier:@"offering"];
        __unused RCPaywallViewController *view3 = [proxy createPaywallViewWithOfferingIdentifier:@"offering" presentedOfferingContext:@{}];
        __unused RCPaywallFooterViewController *footer1 = [proxy createFooterPaywallView];
        __unused RCPaywallFooterViewController *footer2 = [proxy createFooterPaywallViewWithOfferingIdentifier:@"offering"];
        __unused RCPaywallFooterViewController *footer3 = [proxy createFooterPaywallViewWithOfferingIdentifier:@"offering" presentedOfferingContext:@{}];
    }
}

@end

NS_ASSUME_NONNULL_END
