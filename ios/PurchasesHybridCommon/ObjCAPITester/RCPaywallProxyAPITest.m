//
//  RCPaywallProxyAPITest.m
//  ObjCAPITester
//
//  Created by Nacho Soto on 11/7/23.
//  Copyright © 2023 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;
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

        __unused UIViewController *view1 = [proxy createPaywallView];
        __unused UIViewController *view2 = [proxy createPaywallViewWithOfferingIdentifier:@"offering"];
        __unused UIViewController *footer1 = [proxy createFooterPaywallView];
        __unused UIViewController *footer2 = [proxy createFooterPaywallViewWithOfferingIdentifier:@"offering"];
    }
}

@end

NS_ASSUME_NONNULL_END
