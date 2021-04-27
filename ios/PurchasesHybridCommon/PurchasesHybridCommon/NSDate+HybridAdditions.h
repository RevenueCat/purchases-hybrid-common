//
// Created by RevenueCat.
// Copyright (c) 2020 Purchases. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSDate (RCExtensions)

- (NSString *)rc_formattedAsISO8601;
- (double)rc_millisecondsSince1970AsDouble;

@end


NS_ASSUME_NONNULL_END
