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


}
@end

NS_ASSUME_NONNULL_END
