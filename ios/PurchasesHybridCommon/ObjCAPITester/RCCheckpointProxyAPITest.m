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

    // No-factory overload (original API)
    [CheckpointProxy presentWithIdentifier:@"identifier"
                           customVariables:@{@"key": @"value"}
                          presentationMode:sheet
                                  onPassed:^(NSDictionary<NSString *, id> *result) {}
                                   onError:^(NSString *code, NSString *message) {}];

    // Error-dialog-factory overload
    [CheckpointProxy presentWithIdentifier:@"identifier"
                                    callId:@"call-1"
                           customVariables:@{@"key": @"value"}
                          presentationMode:fullScreen
                                  onPassed:^(NSDictionary<NSString *, id> *result) {}
                                   onError:^(NSString *code, NSString *message) {}
                    onErrorDialogRequested:^(NSString *requestId, NSDictionary<NSString *, id> *error) {
                        // Resolve with custom dialog content.
                        [CheckpointProxy resolveErrorDialogWithRequestId:requestId
                                                                 outcome:@{@"type": @"show",
                                                                           @"dialog": @{@"message": @"Try again",
                                                                                        @"buttonTitle": @"OK"}}];
                    }];

    // Resolve with an explicit default or suppressed outcome.
    [CheckpointProxy resolveErrorDialogWithRequestId:@"some-request-id" outcome:@{@"type": @"useDefault"}];
    [CheckpointProxy resolveErrorDialogWithRequestId:@"some-request-id" outcome:@{@"type": @"suppress"}];
    [CheckpointProxy resolveErrorDialogWithRequestId:@"some-request-id" outcome:nil];

    // Cancel pending requests for a specific callId.
    [CheckpointProxy cancelErrorDialogsWithCallId:@"call-1"];

    // Cancel all pending requests.
    [CheckpointProxy cancelErrorDialogsWithCallId:nil];

    // Suppress unused-variable warnings.
    (void)notConfigured;
    (void)unsupported;
}

@end

NS_ASSUME_NONNULL_END
