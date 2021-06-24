//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

#import <Purchases/Purchases.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCErrorContainer : NSObject

@property (nonatomic, readonly) NSInteger code;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSDictionary *info;
@property (nonatomic, readonly) NSError *error;

- (instancetype)initWithError:(NSError *)error extraPayload:(NSDictionary *)extraPayload;

@end

NS_ASSUME_NONNULL_END
