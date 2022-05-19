//
//  RCErrorContainerAPITests.m
//  ObjCAPITester
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PurchasesHybridCommon;

NS_ASSUME_NONNULL_BEGIN

@interface RCErrorContainerAPITests: NSObject

@end


@implementation RCErrorContainerAPITests: NSObject

- (void)testAPI {

    RCErrorContainer *container = [[RCErrorContainer alloc] initWithError:[[NSError alloc] init]
                                                             extraPayload:@{}];
    NSInteger code __unused = container.code;
    NSString *message __unused = container.message;
    NSDictionary *info __unused = container.info;
    NSError *error __unused = container.error;

}

@end

NS_ASSUME_NONNULL_END
