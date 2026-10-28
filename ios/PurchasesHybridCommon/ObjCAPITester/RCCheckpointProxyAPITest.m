//
//  RCCheckpointProxyAPITest.m
//  ObjCAPITester
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

@import Foundation;
@import PurchasesHybridCommonUI;

NS_ASSUME_NONNULL_BEGIN

@interface RCCheckpointProxyAPITest : NSObject

@end

@implementation RCCheckpointProxyAPITest

- (void)testAPI {
    NSString *fullScreen = CheckpointProxy.presentationModeFullScreen;
    NSString *sheet = CheckpointProxy.presentationModeSheet;
    NSString *notConfigured = CheckpointProxy.notConfiguredErrorCode;
    NSString *unsupported = CheckpointProxy.unsupportedOSVersionErrorCode;

    [CheckpointProxy presentWithIdentifier:@"identifier"
                           customVariables:@{@"key": @"value"}
                          presentationMode:sheet
                                  onPassed:^(NSDictionary<NSString *, id> *result) {}
                                   onError:^(NSString *code, NSString *message) {}];
}

@end

NS_ASSUME_NONNULL_END
