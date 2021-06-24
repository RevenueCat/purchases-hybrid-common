//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import "RCErrorContainer.h"


@interface RCErrorContainer ()

@property (nonatomic, readwrite) NSInteger code;
@property (nonatomic, nonnull, readwrite) NSString *message;
@property (nonatomic, nonnull, readwrite) NSDictionary *info;
@property (nonatomic, nonnull, readwrite) NSError *error;

@end

@implementation RCErrorContainer

- (instancetype)initWithError:(NSError *)error extraPayload:(NSDictionary *)extraPayload {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:extraPayload];
    dict[@"code"] = @(error.code);
    dict[@"message"] = error.localizedDescription;
    if (error.userInfo[NSUnderlyingErrorKey]) {
        dict[@"underlyingErrorMessage"] = ((NSError *) error.userInfo[NSUnderlyingErrorKey]).localizedDescription;
    } else {
        dict[@"underlyingErrorMessage"] = @"";
    }

    if (error.userInfo[RCReadableErrorCodeKey]) {
        NSString *readableErrorCode = error.userInfo[RCReadableErrorCodeKey];
        dict[@"readableErrorCode"] = readableErrorCode;
        dict[@"readable_error_code"] = readableErrorCode;
            
        NSMutableDictionary *fixedUserInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
        fixedUserInfo[@"readableErrorCode"] = readableErrorCode;
                
        error = [NSError errorWithDomain:error.domain code:error.code userInfo:fixedUserInfo];
    }

    if (self = [super init]) {
        self.code = error.code;
        self.message = error.localizedDescription;
        self.info = dict;
        self.error = error;
    }
    return self;
}

@end
