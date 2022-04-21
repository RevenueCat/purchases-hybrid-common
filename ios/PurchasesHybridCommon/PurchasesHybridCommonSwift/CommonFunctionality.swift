//
//  CommonFunctionality.swift
//  PurchasesHybridCommonSwift
//
//  Created by Andrés Boedo on 4/19/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import StoreKit
import Purchases


@objc(RCCommonFunctionality) public class CommonFunctionality: NSObject {

    // MARK: properties and configuration
    @objc public static var simulatesAskToBuyInSandbox: Bool = false
    @objc public static var appUserID: String { Purchases.shared.appUserID }
    @objc public static var isAnonymous: Bool { Purchases.shared.isAnonymous }

    @objc public static var proxyURLString: String? {
        get { Purchases.proxyURL?.absoluteString }
        set {
            if let value = newValue {
                guard let proxyURL = URL(string: value) else {
                    fatalError("could not set the proxyURL, provided value is not a valid URL: \(value)")
                }
                Purchases.proxyURL = proxyURL
            } else {
                Purchases.proxyURL = nil
            }
        }
    }

    @objc public var simulatesAskToBuyInSandbox: Bool {
        get {
            // all other platforms already support this feature
            if #available(macOS 10.14, *) {
                return Purchases.simulatesAskToBuyInSandbox
            } else {
                return false
            }
        }
        set {
            // all other platforms already support this feature
            if #available(macOS 10.14, *) {
                Purchases.simulatesAskToBuyInSandbox = newValue
            } else {
                NSLog("called setSimulatesAskToBuyInSandbox, but it's not available on this platform / OS version")
            }
        }
    }

    // Note: we can't have a property that's only available on certain OS versions,
    // so _discountsByProductIdentifier and discountsByProductIdentifier provide for a way
    // to have one.
    private static var _discountsByProductIdentifier: Any? = nil

    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *)
    private static var discountsByProductIdentifier: [String: SKPaymentDiscount] {
        get {
            return _discountsByProductIdentifier as! [String: SKPaymentDiscount]
        } set {
            _discountsByProductIdentifier = newValue
        }
    }

    @objc public static func configure() {
        // todo: it seems like this call isn't needed anymore?
    }

    @objc public static func setAllowSharingStoreAccount(_ allowSharingStoreAccount: Bool) {
        Purchases.shared.allowSharingAppStoreAccount = allowSharingStoreAccount;
    }

    @objc public static func setDebugLogsEnabled(_ enabled: Bool) {
        Purchases.logLevel = enabled ? .debug : .info
    }

    @objc public static func setAutomaticAppleSearchAdsAttributionCollection(_ enabled: Bool) {
        Purchases.automaticAppleSearchAdsAttributionCollection = enabled
    }

    @objc public static func setFinishTransactions(_ finishTransactions: Bool) {
        Purchases.shared.finishTransactions = finishTransactions
    }

    @objc public static func invalidatePurchaserInfoCache() {
        Purchases.shared.invalidatePurchaserInfoCache()
    }

    @available(iOS 14.0, *)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @objc public static func presentCodeRedemptionSheet() {
        Purchases.shared.presentCodeRedemptionSheet()
    }

    @objc public static func canMakePaymentsWithFeatures(_ features: [Int]) -> Bool {
        return Purchases.canMakePayments()
    }

}

// MARK: purchasing and restoring
@objc public extension CommonFunctionality {

    @objc(restoreTransactionsWithCompletionBlock:)
    static func restoreTransactions(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let purchaserInfoCompletion = purchaserInfoCompletionBlock(from: completion)
        Purchases.shared.restoreTransactions(purchaserInfoCompletion)
    }

    @objc(syncPurchasesWithCompletionBlock:)
    static func syncPurchases(completion: (([String: Any]?, ErrorContainer?) -> Void)?) {
        if let completion = completion {
            let purchaserInfoCompletion = purchaserInfoCompletionBlock(from: completion)
            Purchases.shared.syncPurchases(purchaserInfoCompletion)
        } else {
            Purchases.shared.syncPurchases(nil)
        }
    }

    @objc(purchaseProduct:signedDiscountTimestamp:completionBlock:)
    static func purchaseProduct(_ productIdentifier: String,
                                signedDiscountTimestamp: String?,
                                completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let hybridCompletion: (SKPaymentTransaction?,
                               Purchases.PurchaserInfo?,
                               Error?,
                               Bool) -> Void = { transaction, purchaserInfo, error, userCancelled in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: ["userCancelled": userCancelled]))
            } else if let purchaserInfo = purchaserInfo,
                      let transaction = transaction {
                completion([
                    "purchaserInfo": purchaserInfo.dictionary,
                    "productIdentifier": transaction.payment.productIdentifier
                ], nil)
            } else {
                // todo: maybe set up custom error here?
                completion(nil, productNotFoundError(description: "Couldn't find product.", userCancelled: false))
            }
        }

        product(with: productIdentifier) { product in
            guard let product = product else {
                completion(nil, productNotFoundError(description: "Couldn't find product.", userCancelled: false))
                return
            }

            if let signedDiscountTimestamp = signedDiscountTimestamp {
                if #available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *) {
                    guard let discount = self.discountsByProductIdentifier[signedDiscountTimestamp] else {
                        completion(nil, productNotFoundError(description: "Couldn't find discount.", userCancelled: false))
                        return
                    }
                    Purchases.shared.purchaseProduct(product, discount: discount, hybridCompletion)
                    return
                }

                Purchases.shared.purchaseProduct(product, hybridCompletion)
            }

        }
    }

    @objc(purchasePackage:offering:signedDiscountTimestamp:completionBlock:)
    static func purchasePackage(_ packageIdentifier: String,
                                offeringIdentifier: String,
                                signedDiscountTimestamp: String?,
                                completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let hybridCompletion: (SKPaymentTransaction?,
                               Purchases.PurchaserInfo?,
                               Error?,
                               Bool) -> Void = { transaction, purchaserInfo, error, userCancelled in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: ["userCancelled": userCancelled]))
            } else if let purchaserInfo = purchaserInfo,
                      let transaction = transaction {
                completion([
                    "purchaserInfo": purchaserInfo.dictionary,
                    "productIdentifier": transaction.payment.productIdentifier
                ], nil)
            } else {
                // todo: maybe set up custom error here?
                completion(nil, productNotFoundError(description: "Couldn't find product.", userCancelled: false))
            }
        }

        package(with: packageIdentifier) { package in
            guard let package = package else {
                let error = productNotFoundError(description: "Couldn't find package", userCancelled: false)
                completion(nil, error)
                return
            }

            if let signedDiscountTimestamp = signedDiscountTimestamp {
                if #available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *) {
                    guard let discount = self.discountsByProductIdentifier[signedDiscountTimestamp] else {
                        completion(nil, productNotFoundError(description: "Couldn't find discount.", userCancelled: false))
                        return
                    }
                    Purchases.shared.purchasePackage(package, discount: discount, hybridCompletion)
                    return
                }

            }

            Purchases.shared.purchasePackage(package, hybridCompletion)
        }

    }

    @objc(makeDeferredPurchase:completionBlock:)
    static func makeDeferredPurchase(_ startPurchase: RCDeferredPromotionalPurchaseBlock,
                                     completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        startPurchase { transaction, purchaserInfo, error, userCancelled in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: ["userCancelled": userCancelled]))
            } else if let purchaserInfo = purchaserInfo,
                      let transaction = transaction {
                completion([
                    "purchaserInfo": purchaserInfo.dictionary,
                    "productIdentifier": transaction.payment.productIdentifier
                ], nil)
            } else {
                let error = NSError(domain: Purchases.ErrorDomain,
                                    code: Purchases.ErrorCode.unknownError.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: description])

                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            }
        }
    }

}

// MARK: identity
@objc public extension CommonFunctionality {

    @objc(logInWithAppUserID:completionBlock:)
    static func logIn(appUserID: String, completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.logIn(appUserID) { purchaserInfo, created, error in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            } else if let purchaserInfo = purchaserInfo {
                completion([
                    "purchaserInfo": purchaserInfo.dictionary,
                    "created": created
                ], nil)
            } else {
                let error = NSError(domain: Purchases.ErrorDomain,
                                    code: Purchases.ErrorCode.unknownError.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: description])

                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            }
        }
    }

    @objc(logOutWithCompletionBlock:)
    static func logOut(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.logOut(purchaserInfoCompletionBlock(from: completion))
    }

    @objc(createAlias:completionBlock:)
    static func createAlias(newAppUserID: String, completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.createAlias(newAppUserID, purchaserInfoCompletionBlock(from: completion))
    }

    @objc(identify:completionBlock:)
    static func identify(appUserID: String, completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.identify(appUserID, purchaserInfoCompletionBlock(from: completion))
    }

    @objc(resetWithCompletionBlock:)
    static func reset(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.reset(purchaserInfoCompletionBlock(from: completion))
    }

    @objc(getPurchaserInfoWithCompletionBlock:)
    static func purchaserInfo(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.purchaserInfo(purchaserInfoCompletionBlock(from: completion))
    }

}

// MARK: offerings and eligibility
@objc public extension CommonFunctionality {

    @objc(getOfferingsWithCompletionBlock:)
    static func getOfferings(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.offerings { offerings, error in
            if let error = error {
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])
                completion(nil, errorContainer)
            } else {
                completion(offerings?.dictionary, nil)
            }
        }
    }


    @objc(checkTrialOrIntroductoryPriceEligibility:completionBlock:)
    static func checkTrialOrIntroductoryPriceEligibility(
        for products: [String],
        completion: @escaping([String: Any]) -> Void) {
            Purchases.shared.checkTrialOrIntroductoryPriceEligibility(products) { eligibilityByProductId in
                completion(eligibilityByProductId.mapValues { [
                    "status": $0.status,
                    "description": $0.description
                ]
                })
            }
        }


    @objc static func getProductInfo(_ productIds: [String], completionBlock: @escaping([[String: Any]]) -> Void) {
        Purchases.shared.products(productIds) { products in
            let productDictionaries = products.map { $0.rc_dictionary }
            completionBlock(productDictionaries)
        }
    }

    @objc(paymentDiscountForProductIdentifier:discount:completionBlock:)
    static func paymentDiscount(for productIdentifier: String,
                                discountIdentifier: String?,
                                completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        guard #available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *) else {
            completion(nil, nil)
            return
        }

        product(with: productIdentifier) { product in
            guard let product = product else {
                completion(nil, productNotFoundError(description: "Couldn't find product", userCancelled: false))
                return
            }

            guard let discountToUse = discount(with: discountIdentifier, for: product) else {
                completion(nil, productNotFoundError(description: "Couldn't find discount", userCancelled: false))
                return
            }

            let paymentDiscountCompletion: (SKPaymentDiscount?, Error?) -> Void = { discount, error in
                guard let discount = discount else {
                    if let error = error {
                        completion(nil, ErrorContainer(error: error, extraPayload: [:]))
                    } else {
                        let error = NSError(domain: Purchases.ErrorDomain,
                                            code: Purchases.ErrorCode.unknownError.rawValue,
                                            userInfo: [NSLocalizedDescriptionKey: description])

                        completion(nil, ErrorContainer(error: error, extraPayload: [:]))
                    }
                    return
                }
                discountsByProductIdentifier[discount.timestamp.stringValue] = discount
                completion(discount.rc_dictionary, nil)
            }

            Purchases.shared.paymentDiscount(for: discountToUse,
                                             product: product,
                                             completion: paymentDiscountCompletion)

        }
    }

}

// MARK: Subscriber attributes
@objc public extension CommonFunctionality {

    @objc static func setAttributes(_ attributes: [String: Any]) {
        Purchases.shared.setAttributes(attributes.mapValues { $0 as? String ?? "" })
    }

    @objc static func setEmail(_ email: String?) {
        Purchases.shared.setEmail(email)
    }

    @objc static func setPhoneNumber(_ phoneNumber: String?) {
        Purchases.shared.setPhoneNumber(phoneNumber)
    }

    @objc static func setDisplayName(_ displayName: String?) {
        Purchases.shared.setDisplayName(displayName)
    }

    @objc static func setPushToken(_ pushToken: String?) {
        // todo
        // this method has been temporarily removed and will be re-added
        // when this code is adapted for v4
        // Purchases.shared.setPushToken(pushToken)
    }

}

// MARK: Attribution IDs
@objc public extension CommonFunctionality {

    @objc static func collectDeviceIdentifiers() {
        Purchases.shared.collectDeviceIdentifiers()
    }

    @objc static func setAdjustID(_ adjustID: String?) {
        Purchases.shared.setAdjustID(adjustID)
    }
    @objc static func setAppsflyerID(_ appsflyerID: String?) {
        Purchases.shared.setAppsflyerID(appsflyerID)
    }
    @objc static func setFBAnonymousID(_ fbAnonymousID: String?) {
        Purchases.shared.setFBAnonymousID(fbAnonymousID)
    }
    @objc static func setMparticleID(_ mParticleID: String?) {
        Purchases.shared.setMparticleID(mParticleID)
    }
    @objc static func setOnesignalID(_ onesignalID: String?) {
        Purchases.shared.setOnesignalID(onesignalID)
    }
    @objc static func setAirshipChannelID(_ airshipChannelID: String?) {
        Purchases.shared.setAirshipChannelID(airshipChannelID)
    }

    @objc static func addAttributionData(_ data: [String: Any], network: Int, networkUserId: String) {
        // todo: clean up force cast after migration to v4
        Purchases.addAttributionData(data,
                                     from: RCAttributionNetwork(rawValue: network)!,
                                     forNetworkUserId: networkUserId)
    }

}

// MARK: Campaign parameters
@objc public extension CommonFunctionality {

    @objc static func setMediaSource(_ mediaSource: String?) {
        Purchases.shared.setMediaSource(mediaSource)
    }
    @objc static func setCampaign(_ campaign: String?) {
        Purchases.shared.setCampaign(campaign)
    }
    @objc static func setAdGroup(_ adGroup: String?) {
        Purchases.shared.setAdGroup(adGroup)
    }
    @objc static func setAd(_ ad: String?) {
        Purchases.shared.setAd(ad)
    }
    @objc static func setKeyword(_ keyword: String?) {
        Purchases.shared.setKeyword(keyword)
    }
    @objc static func setCreative(_ creative: String?) {
        Purchases.shared.setCreative(creative)
    }

}

private extension CommonFunctionality {

    static func purchaserInfoCompletionBlock(from block: @escaping ([String: Any]?, ErrorContainer?) -> Void)
    -> ((Purchases.PurchaserInfo?, Error?) -> Void) {
        return { purchaserInfo, error in
            if let error = error {
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])
                block(nil, errorContainer)
            } else if let purchaserInfo = purchaserInfo {
                block(purchaserInfo.dictionary, nil)
            } else {
                fatalError("got nil error and nil purchaserInfo")
            }
        }

    }

    static func product(with identifier: String, completion: @escaping (SKProduct?) -> Void) {
        Purchases.shared.products([identifier]) { products in
            completion(products.first { $0.productIdentifier == identifier })
        }
    }

    static func productNotFoundError(description: String, userCancelled: Bool?) -> ErrorContainer {
        var extraPayload: [String: Any] = [:]
        if let userCancelled = userCancelled {
            extraPayload["userCancelled"] = userCancelled
        }

        let error = NSError(domain: Purchases.ErrorDomain,
                            code: Purchases.ErrorCode.productNotAvailableForPurchaseError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: description])
        return ErrorContainer(error: error, extraPayload: extraPayload)
    }

    static func package(with identifier: String, completion: @escaping(Purchases.Package?) -> Void) {
        Purchases.shared.offerings { offerings, error in
            let offering = offerings?.offering(identifier: identifier)
            let package = offering?.package(identifier: identifier)
            completion(package)
        }
    }

    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *)
    static func discount(with identifier: String?, for product: SKProduct) -> SKProductDiscount? {
        if identifier == nil {
            return product.discounts.first
        } else {
            return product.discounts.first { $0.identifier == identifier }
        }
    }

}
