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
        dict[RCReadableErrorCodeKey] = readableErrorCode;
        
        // Reason behind this is because React Native doens't let reject the promises passing more information
        // besides passing the original error, but it passes the extra userInfo from that error to the JS layer.
        // Since we want to pass both readable_error_code (deprecated) and readableErrorCode when building the
        // error JS object, and the error coming from purchases-ios only has the snake case version, we need to
        // add readableErrorCode to the userInfo of the error. In a future project, we will remove the
        // deprecated version and also improve error handling so it's easier to detect which errors come
        // from RevenueCat and which don't
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
