//
//  NSDate+HybridAdditionsAPITest.m
//  ObjCAPITester
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

@import PurchasesHybridCommonSwift;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDateHybridAdditionsAPITest: NSObject

@end

@implementation NSDateHybridAdditionsAPITest

- (void)testAPI {
    NSDate *date __unused = [[NSDate alloc] init];
    NSString *string __unused = [date rc_formattedAsISO8601];
    double milliseconds __unused = [date rc_millisecondsSince1970AsDouble];
}

@end


NS_ASSUME_NONNULL_END
