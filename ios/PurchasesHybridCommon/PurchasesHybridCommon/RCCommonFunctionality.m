//
//  Created by RevenueCat.
//  Copyright © 2019 RevenueCat. All rights reserved.
//
#import "RCCommonFunctionality.h"
#import "SKProduct+HybridAdditions.h"
#import "RCErrorContainer.h"
#import "RCOfferings+HybridAdditions.h"
#import "RCPurchaserInfo+HybridAdditions.h"
#import "SKPaymentDiscount+HybridAdditions.h"
#import "RCPurchases+HybridAdditions.h"


API_AVAILABLE(ios(12.2), macos(10.14.4), tvos(12.2))
@interface RCCommonFunctionality ()

@property (class, readonly, nonatomic, retain) NSMutableDictionary<NSString *, SKPaymentDiscount *> *discounts;

@end


@implementation RCCommonFunctionality

API_AVAILABLE(ios(12.2), macos(10.14.4), tvos(12.2))
static NSMutableDictionary<NSString *, SKPaymentDiscount *> *_discounts = nil;

+ (NSMutableDictionary<NSString *, SKPaymentDiscount *> *)discounts
API_AVAILABLE(ios(12.2), macos(10.14.4), tvos(12.2)) {
    return _discounts;
}

+ (void)configure {
    if (@available(iOS 12.2, macos 10.14.4, tvOS 12.2, *)) {
        _discounts = [NSMutableDictionary new];
    }
}

+ (void)setAllowSharingStoreAccount:(BOOL)allowSharingStoreAccount {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    RCPurchases.sharedPurchases.allowSharingAppStoreAccount = allowSharingStoreAccount;
}

+ (void)addAttributionData:(NSDictionary *)data network:(NSInteger)network networkUserId:(NSString *)networkUserId {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [RCPurchases addAttributionData:data fromNetwork:(RCAttributionNetwork) network forNetworkUserId:networkUserId];
#pragma GCC diagnostic pop
}

+ (void)getProductInfo:(NSArray *)products
       completionBlock:(void (^)(NSArray<NSDictionary *> *))completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");

    [RCPurchases.sharedPurchases productsWithIdentifiers:products
                                         completionBlock:^(NSArray<SKProduct *> *_Nonnull products) {
                                             NSMutableArray *productObjects = [NSMutableArray new];
                                             for (SKProduct *p in products) {
                                                 [productObjects addObject:p.rc_dictionary];
                                             }
                                             completion(productObjects);
                                         }];
}

+ (void)restoreTransactionsWithCompletionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    [RCPurchases.sharedPurchases restoreTransactionsWithCompletionBlock:[self getPurchaserInfoCompletionBlock:completion]];
}

+ (void)syncPurchasesWithCompletionBlock:(nullable RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");

    void (^purchaserInfoCompletion)(RCPurchaserInfo *, NSError *) = completion ? [self getPurchaserInfoCompletionBlock:completion]
                                                                               : nil;
    [RCPurchases.sharedPurchases syncPurchasesWithCompletionBlock:purchaserInfoCompletion];
}

+ (NSString *)appUserID {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    return RCPurchases.sharedPurchases.appUserID;
}


+ (void)logInWithAppUserID:(NSString *)appUserId completionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    [RCPurchases.sharedPurchases logIn:appUserId
                       completionBlock:^(RCPurchaserInfo * _Nullable purchaserInfo,
                                         BOOL created,
                                         NSError * _Nullable error) {
                           if (error) {
                               RCErrorContainer *errorContainer = [[RCErrorContainer alloc] initWithError:error
                                                                                             extraPayload:@{}];
                               completion(nil, errorContainer);
                           } else {
                               completion(@{
                                              @"purchaserInfo": purchaserInfo.dictionary,
                                              @"created": @(created)
                                          }, nil);
                           }
                       }];
}

+ (void)logOutWithCompletionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    [RCPurchases.sharedPurchases logOutWithCompletionBlock:[self getPurchaserInfoCompletionBlock:completion]];
}

+ (void)createAlias:(nullable NSString *)newAppUserID completionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [RCPurchases.sharedPurchases createAlias:newAppUserID
                             completionBlock:[self getPurchaserInfoCompletionBlock:completion]];
    #pragma GCC diagnostic pop
}

+ (void)identify:(NSString *)appUserID completionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [RCPurchases.sharedPurchases identify:appUserID completionBlock:[self getPurchaserInfoCompletionBlock:completion]];
    #pragma GCC diagnostic pop
}

+ (void)resetWithCompletionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [RCPurchases.sharedPurchases resetWithCompletionBlock:[self getPurchaserInfoCompletionBlock:completion]];
    #pragma GCC diagnostic pop
}

+ (void)setDebugLogsEnabled:(BOOL)enabled {
    RCPurchases.logLevel = enabled ? RCLogLevelDebug : RCLogLevelInfo;
}

+ (void)setProxyURLString:(nullable NSString *)proxyURLString {
    NSURL *proxyURL = [NSURL URLWithString:proxyURLString];
    if (proxyURLString != nil && proxyURL == nil) {
        NSAssert(false, @"couldn't parse the proxy URL string \"%@\" into a valid URL!", proxyURLString);
    }
    RCPurchases.proxyURL = [NSURL URLWithString:proxyURLString];
}

+ (nullable NSString *)proxyURLString {
    return RCPurchases.proxyURL.absoluteString;
}

+ (BOOL)simulatesAskToBuyInSandbox {
    if (@available(iOS 8.0, macos 10.14, tvOS 9.0, watchos 6.2, macCatalyst 13.0, *)) {
        return RCPurchases.simulatesAskToBuyInSandbox;
    } else {
        NSLog(@"called simulatesAskToBuyInSandbox, but it's not available on this platform / OS version");
        return NO;
    }
}

+ (void)setSimulatesAskToBuyInSandbox:(BOOL)simulatesAskToBuyInSandbox {
    if (@available(iOS 8.0, macos 10.14, tvOS 9.0, watchos 6.2, macCatalyst 13.0, *)) {
        RCPurchases.simulatesAskToBuyInSandbox = simulatesAskToBuyInSandbox;
    } else {
        NSLog(@"called setSimulatesAskToBuyInSandbox, but it's not available on this platform / OS version");
    }
}

+ (void)getPurchaserInfoWithCompletionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    [RCPurchases.sharedPurchases purchaserInfoWithCompletionBlock:[self getPurchaserInfoCompletionBlock:completion]];
}

+ (void)setAutomaticAppleSearchAdsAttributionCollection:(BOOL)enabled {
    RCPurchases.automaticAppleSearchAdsAttributionCollection = enabled;
}

+ (void)getOfferingsWithCompletionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    [RCPurchases.sharedPurchases offeringsWithCompletionBlock:^(RCOfferings * _Nullable offerings,
                                                                NSError * _Nullable error) {
        if (error) {
            RCErrorContainer *errorContainer = [[RCErrorContainer alloc] initWithError:error extraPayload:@{}];
            completion(nil, errorContainer);
        } else {
            completion(offerings.dictionary, nil);
        }
    }];
}

+ (BOOL)isAnonymous {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    return [RCPurchases.sharedPurchases isAnonymous];
}

+ (void)purchaseProduct:(NSString *)productIdentifier
signedDiscountTimestamp:(nullable NSString *)discountTimestamp
        completionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");

    void
    (^completionBlock)(SKPaymentTransaction * _Nullable, RCPurchaserInfo * _Nullable, NSError * _Nullable, BOOL) = ^(
        SKPaymentTransaction * _Nullable transaction,
        RCPurchaserInfo * _Nullable purchaserInfo,
        NSError * _Nullable error,
        BOOL userCancelled) {
        if (error) {
            NSDictionary *extraPayload = @{@"userCancelled": @(userCancelled)};
            RCErrorContainer *errorContainer = [[RCErrorContainer alloc] initWithError:error extraPayload:extraPayload];
            completion(nil, errorContainer);
        } else {
            completion(@{
                           @"purchaserInfo": purchaserInfo.dictionary,
                           @"productIdentifier": transaction.payment.productIdentifier
                       }, nil);
        }
    };

    [self productWithIdentifier:productIdentifier completionBlock:^(SKProduct * _Nullable aProduct) {
        if (aProduct == nil) {
            [self productNotFoundErrorWithDescription:@"Couldn't find product."
                                        userCancelled:[NSNumber numberWithBool:NO]
                                           completion:completion];
            return;
        }

        if (@available(iOS 12.2, macos 10.14.4, tvOS 12.2, *)) {
            if (discountTimestamp) {
                SKPaymentDiscount *discount = self.discounts[discountTimestamp];
                if (discount == nil) {
                    [self productNotFoundErrorWithDescription:@"Couldn't find discount."
                                                userCancelled:[NSNumber numberWithBool:NO]
                                                   completion:completion];
                    return;
                }

                [RCPurchases.sharedPurchases purchaseProduct:aProduct
                                                withDiscount:discount
                                             completionBlock:completionBlock];
                return;
            }
        }

        [RCPurchases.sharedPurchases purchaseProduct:aProduct withCompletionBlock:completionBlock];
    }];
}

+ (void)purchasePackage:(NSString *)packageIdentifier
               offering:(NSString *)offeringIdentifier
signedDiscountTimestamp:(nullable NSString *)discountTimestamp
        completionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");

    void
    (^completionBlock)(SKPaymentTransaction * _Nullable, RCPurchaserInfo * _Nullable, NSError * _Nullable, BOOL) = ^(
        SKPaymentTransaction * _Nullable transaction,
        RCPurchaserInfo * _Nullable purchaserInfo,
        NSError * _Nullable error,
        BOOL userCancelled) {
        if (error) {
            NSDictionary *extraPayload = @{@"userCancelled": @(userCancelled)};
            RCErrorContainer *errorContainer = [[RCErrorContainer alloc] initWithError:error extraPayload:extraPayload];
            completion(nil, errorContainer);
        } else {
            completion(@{
                           @"purchaserInfo": purchaserInfo.dictionary,
                           @"productIdentifier": transaction.payment.productIdentifier
                       }, nil);
        }
    };

    [self packageWithIdentifier:packageIdentifier
             offeringIdentifier:offeringIdentifier
                completionBlock:^(RCPackage * _Nullable aPackage) {
                    if (aPackage == nil) {
                        [self productNotFoundErrorWithDescription:@"Couldn't find package."
                                                    userCancelled:[NSNumber numberWithBool:NO]
                                                       completion:completion];
                        return;
                    }

                    if (@available(iOS 12.2, macos 10.14.4, tvOS 12.2, *)) {
                        if (discountTimestamp) {
                            SKPaymentDiscount *discount = self.discounts[discountTimestamp];
                            if (discount == nil) {
                                [self productNotFoundErrorWithDescription:@"Couldn't find discount."
                                                            userCancelled:[NSNumber numberWithBool:NO]
                                                               completion:completion];
                                return;
                            }

                            [RCPurchases.sharedPurchases purchasePackage:aPackage
                                                            withDiscount:discount
                                                         completionBlock:completionBlock];
                            return;
                        }
                    }

                    [RCPurchases.sharedPurchases purchasePackage:aPackage withCompletionBlock:completionBlock];
                }];
}

+ (void)setFinishTransactions:(BOOL)finishTransactions {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    RCPurchases.sharedPurchases.finishTransactions = finishTransactions;
}

+ (void)makeDeferredPurchase:(RCDeferredPromotionalPurchaseBlock)deferredPurchase
             completionBlock:(RCHybridResponseBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");

    deferredPurchase(^(SKPaymentTransaction * _Nullable transaction,
                       RCPurchaserInfo * _Nullable purchaserInfo,
                       NSError * _Nullable error,
                       BOOL userCancelled) {
        if (error) {
            NSDictionary *extraPayload = @{@"userCancelled": @(userCancelled)};
            RCErrorContainer *errorContainer = [[RCErrorContainer alloc] initWithError:error extraPayload:extraPayload];
            completion(nil, errorContainer);
        } else {
            completion(@{
                           @"purchaserInfo": purchaserInfo.dictionary,
                           @"productIdentifier": transaction.payment.productIdentifier
                       }, nil);
        }
    });
}

+ (void)checkTrialOrIntroductoryPriceEligibility:(nonnull NSArray<NSString *> *)productIdentifiers
                                 completionBlock:(RCReceiveIntroEligibilityBlock)completion {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");

    [RCPurchases.sharedPurchases checkTrialOrIntroductoryPriceEligibility:productIdentifiers
                                                          completionBlock:^(NSDictionary<NSString *, RCIntroEligibility *> *_Nonnull dictionary) {
                                                              NSMutableDictionary *response = [NSMutableDictionary new];
                                                              for (NSString *productID in dictionary) {
                                                                  RCIntroEligibility
                                                                      *eligibility = dictionary[productID];
                                                                  response[productID] = @{
                                                                      @"status": @(eligibility.status),
                                                                      @"description": eligibility.description
                                                                  };
                                                              }
                                                              completion([NSDictionary dictionaryWithDictionary:response]);
                                                          }];
}

+ (void)paymentDiscountForProductIdentifier:(NSString *)productIdentifier
                                   discount:(nullable NSString *)discountIdentifier
                            completionBlock:(RCHybridResponseBlock)completion {
    if (@available(iOS 12.2, macos 10.14.4, tvOS 12.2, *)) {
        NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
        [self productWithIdentifier:productIdentifier completionBlock:^(SKProduct * _Nullable aProduct) {
            if (aProduct) {
                SKProductDiscount *discountToUse = [self discountWithIdentifier:discountIdentifier forProduct:aProduct];

                if (discountToUse) {
                    void (^paymentDiscountCompletion)(SKPaymentDiscount *, NSError *) =
                    ^(SKPaymentDiscount *paymentDiscount, NSError *error) {
                        if (paymentDiscount) {
                            self.discounts[[paymentDiscount.timestamp stringValue]] = paymentDiscount;
                            completion(paymentDiscount.rc_dictionary, nil);
                        } else {
                            RCErrorContainer *errorContainer = 
                                    [[RCErrorContainer alloc] initWithError:error extraPayload:@{}];
                            completion(nil, errorContainer);
                        }
                    };
                    [RCPurchases.sharedPurchases paymentDiscountForProductDiscount:discountToUse
                                                                           product:aProduct
                                                                        completion:paymentDiscountCompletion];
                } else {
                    [self productNotFoundErrorWithDescription:@"Couldn't find discount."
                                                userCancelled:nil
                                                   completion:completion];
                }
            } else {
                [self productNotFoundErrorWithDescription:@"Couldn't find product."
                                            userCancelled:nil
                                               completion:completion];
            }

        }];
    } else {
        completion(nil, nil);
    }
}

+ (void (^)(RCPurchaserInfo *, NSError *))getPurchaserInfoCompletionBlock:(RCHybridResponseBlock)completion {
    return ^(RCPurchaserInfo * _Nullable purchaserInfo, NSError * _Nullable error) {
        if (error) {
            RCErrorContainer *errorContainer = [[RCErrorContainer alloc] initWithError:error extraPayload:@{}];
            completion(nil, errorContainer);
        } else {
            completion(purchaserInfo.dictionary, nil);
        }
    };
}

+ (void)invalidatePurchaserInfoCache {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    [RCPurchases.sharedPurchases invalidatePurchaserInfoCache];
}

+ (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0)) API_UNAVAILABLE(tvos, macos, watchos) {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    [RCPurchases.sharedPurchases presentCodeRedemptionSheet];
}

#pragma mark - Subcriber Attributes

+ (void)setAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSMutableDictionary *nonNilAttributes = [[NSMutableDictionary alloc] init];
    for (NSString *key in attributes.allKeys) {
        id object = attributes[key];
        NSString *nonNilAttribute = ([object isEqual:NSNull.null])
                                    ? @""
                                    : object;
        nonNilAttributes[key] = nonNilAttribute;
    }
    [RCPurchases.sharedPurchases setAttributes:nonNilAttributes];
}

+ (void)setEmail:(nullable NSString *)email {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:email];
    [RCPurchases.sharedPurchases setEmail:nonNSNullAttribute];
}

+ (void)setPhoneNumber:(nullable NSString *)phoneNumber {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:phoneNumber];
    [RCPurchases.sharedPurchases setPhoneNumber:nonNSNullAttribute];
}

+ (void)setDisplayName:(nullable NSString *)displayName {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:displayName];
    [RCPurchases.sharedPurchases setDisplayName:nonNSNullAttribute];
}

+ (void)setPushToken:(nullable NSString *)pushToken {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:pushToken];
    [RCPurchases.sharedPurchases _setPushTokenString:nonNSNullAttribute];
}

#pragma mark Attribution IDs

+ (void)collectDeviceIdentifiers {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    [RCPurchases.sharedPurchases collectDeviceIdentifiers];
}

+ (void)setAdjustID:(nullable NSString *)adjustID {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:adjustID];
    [RCPurchases.sharedPurchases setAdjustID:nonNSNullAttribute];
}

+ (void)setAppsflyerID:(nullable NSString *)appsflyerID {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:appsflyerID];
    [RCPurchases.sharedPurchases setAppsflyerID:nonNSNullAttribute];
}

+ (void)setFBAnonymousID:(nullable NSString *)fbAnonymousID {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:fbAnonymousID];
    [RCPurchases.sharedPurchases setFBAnonymousID:nonNSNullAttribute];
}

+ (void)setMparticleID:(nullable NSString *)mparticleID {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:mparticleID];
    [RCPurchases.sharedPurchases setMparticleID:nonNSNullAttribute];
}

+ (void)setOnesignalID:(nullable NSString *)onesignalID {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:onesignalID];
    [RCPurchases.sharedPurchases setOnesignalID:nonNSNullAttribute];
}

+ (void)setAirshipChannelID:(nullable NSString *)airshipChannelID {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:airshipChannelID];
    [RCPurchases.sharedPurchases setAirshipChannelID:nonNSNullAttribute];
}

#pragma mark Campaign parameters

+ (void)setMediaSource:(nullable NSString *)mediaSource {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:mediaSource];
    [RCPurchases.sharedPurchases setMediaSource:nonNSNullAttribute];
}

+ (void)setCampaign:(nullable NSString *)campaign {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:campaign];
    [RCPurchases.sharedPurchases setCampaign:nonNSNullAttribute];
}

+ (void)setAdGroup:(nullable NSString *)adGroup {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:adGroup];
    [RCPurchases.sharedPurchases setAdGroup:nonNSNullAttribute];
}

+ (void)setAd:(nullable NSString *)ad {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:ad];
    [RCPurchases.sharedPurchases setAd:nonNSNullAttribute];
}

+ (void)setKeyword:(nullable NSString *)keyword {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:keyword];
    [RCPurchases.sharedPurchases setKeyword:nonNSNullAttribute];
}

+ (void)setCreative:(nullable NSString *)creative {
    NSAssert(RCPurchases.sharedPurchases, @"You must call setup first.");
    NSString *nonNSNullAttribute = [self nonNSNullAttribute:creative];
    [RCPurchases.sharedPurchases setCreative:nonNSNullAttribute];
}

+ (NSString * _Nullable)nonNSNullAttribute:(NSString * _Nullable)attribute {
    return ([attribute isEqual:NSNull.null]) ? @"" : attribute;
}

#pragma mark - errors

+ (void)productNotFoundErrorWithDescription:(NSString *)errorDescription
                              userCancelled:(nullable NSNumber *)userCancelled
                                 completion:(RCHybridResponseBlock)completion {
    NSDictionary *extraPayload;
    if (userCancelled == nil) {
        extraPayload = @{};
    } else {
        extraPayload = @{@"userCancelled": @([userCancelled boolValue])};
    }

    NSError *error = [NSError errorWithDomain:RCPurchasesErrorDomain
                                         code:RCProductNotAvailableForPurchaseError
                                     userInfo:@{
                                         NSLocalizedDescriptionKey: errorDescription
                                     }];
    RCErrorContainer *errorContainer = [[RCErrorContainer alloc] initWithError:error extraPayload:extraPayload];
    completion(nil, errorContainer);
}

#pragma mark - helpers

+ (void)productWithIdentifier:(NSString *)productIdentifier
              completionBlock:(void (^)(SKProduct * _Nullable))completion {
    [RCPurchases.sharedPurchases productsWithIdentifiers:@[productIdentifier]
                                         completionBlock:^(NSArray<SKProduct *> *_Nonnull products) {
                                             SKProduct *aProduct = nil;
                                             for (SKProduct *p in products) {
                                                 if ([productIdentifier isEqualToString:p.productIdentifier]) {
                                                     aProduct = p;
                                                 }
                                             }
                                             completion(aProduct);
                                         }];
}

+ (void)packageWithIdentifier:(NSString *)packageIdentifier
           offeringIdentifier:(NSString *)offeringIdentifier
              completionBlock:(void (^)(RCPackage * _Nullable))completion {
    [RCPurchases.sharedPurchases offeringsWithCompletionBlock:^(RCOfferings *offerings, NSError *error) {
        completion([[offerings offeringWithIdentifier:offeringIdentifier] packageWithIdentifier:packageIdentifier]);
    }];
}

+ (nullable SKProductDiscount *)discountWithIdentifier:(NSString *)identifier
                                            forProduct:(SKProduct *)aProduct API_AVAILABLE(ios(12.2),
                                                                                           macos(10.14.4),
                                                                                           tvos(12.2)) {
    SKProductDiscount *discountToUse = nil;
    NSArray<SKProductDiscount *> *productDiscounts = aProduct.discounts;
    if (identifier == nil && productDiscounts != nil && productDiscounts.count > 0) {
        discountToUse = productDiscounts.firstObject;
    } else {
        for (SKProductDiscount *discount in productDiscounts) {
            if ([identifier isEqualToString:discount.identifier]) {
                discountToUse = discount;
            }
        }
    }
    return discountToUse;
}

+ (BOOL)canMakePaymentsWithFeatures:(NSArray<NSNumber *> *)features {
    return [RCPurchases canMakePayments];
}

@end
