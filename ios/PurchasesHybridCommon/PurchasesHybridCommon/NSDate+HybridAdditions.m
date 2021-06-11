//
// Created by RevenueCat.
// Copyright (c) 2020 Purchases. All rights reserved.
//

#import "NSDate+HybridAdditions.h"

NS_ASSUME_NONNULL_BEGIN

static NSDateFormatter *formatter;
static dispatch_once_t onceToken;

static NSString *stringFromDate(NSDate *date) {
    dispatch_once(&onceToken, ^{
        // Here we're not using NSISO8601DateFormatter as we need to support iOS < 10
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter = dateFormatter;
    });

    return [formatter stringFromDate:date];
}

@implementation NSDate (RCExtensions)

- (NSString *)rc_formattedAsISO8601 {
    return stringFromDate(self);
}

- (double)rc_millisecondsSince1970AsDouble {
    return [self timeIntervalSince1970] * 1000.0;
}

@end


NS_ASSUME_NONNULL_END
