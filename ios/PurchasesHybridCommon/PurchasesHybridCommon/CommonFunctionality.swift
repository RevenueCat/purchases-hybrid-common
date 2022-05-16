//
//  CommonFunctionality.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/19/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import StoreKit
import RevenueCat


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

    private static var promoOffersByTimestamp: [String: PromotionalOffer] = [:]

    @available(*, deprecated, message: "Use the set<NetworkId> functions instead")
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

    @objc public static func invalidateCustomerInfoCache() {
        Purchases.shared.invalidateCustomerInfoCache()
    }

#if os(iOS)
    @available(iOS 14.0, *)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @objc public static func presentCodeRedemptionSheet() {
        Purchases.shared.presentCodeRedemptionSheet()
    }
#endif

    @objc public static func canMakePaymentsWithFeatures(_ features: [Int]) -> Bool {
        return Purchases.canMakePayments()
    }

}

// MARK: purchasing and restoring
@objc public extension CommonFunctionality {

    @objc(restorePurchasesWithCompletionBlock:)
    static func restorePurchases(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let customerInfoCompletion = customerInfoCompletionBlock(from: completion)
        Purchases.shared.restorePurchases(completion: customerInfoCompletion)
    }

    @objc(syncPurchasesWithCompletionBlock:)
    static func syncPurchases(completion: (([String: Any]?, ErrorContainer?) -> Void)?) {
        if let completion = completion {
            let customerInfoCompletion = customerInfoCompletionBlock(from: completion)
            Purchases.shared.syncPurchases(completion: customerInfoCompletion)
        } else {
            Purchases.shared.syncPurchases(completion: nil)
        }
    }

    @objc(purchaseProduct:signedDiscountTimestamp:completionBlock:)
    static func purchaseProduct(_ productIdentifier: String,
                                signedDiscountTimestamp: String?,
                                completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let hybridCompletion: (StoreTransaction?,
                               CustomerInfo?,
                               Error?,
                               Bool) -> Void = { transaction, customerInfo, error, userCancelled in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: ["userCancelled": userCancelled]))
            } else if let customerInfo = customerInfo,
                      let transaction = transaction {
                completion([
                    "customerInfo": customerInfo.dictionary,
                    "productIdentifier": transaction.sk1Transaction!.payment.productIdentifier
                ], nil)
            } else {
                let error = NSError(domain: RCPurchasesErrorCodeDomain,
                                    code: ErrorCode.unknownError.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: description])

                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            }
        }

        product(with: productIdentifier) { product in
            guard let product = product else {
                completion(nil, productNotFoundError(description: "Couldn't find product.", userCancelled: false))
                return
            }

            if let signedDiscountTimestamp = signedDiscountTimestamp {
                let storeProduct = StoreProduct(sk1Product: product)
                if #available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *) {
                    guard let promotionalOffer = self.promoOffersByTimestamp[signedDiscountTimestamp] else {
                        completion(nil, productNotFoundError(description: "Couldn't find discount.", userCancelled: false))
                        return
                    }
                    Purchases.shared.purchase(product: storeProduct,
                                              promotionalOffer: promotionalOffer,
                                              completion: hybridCompletion)
                    return
                }

                Purchases.shared.purchase(product: storeProduct, completion: hybridCompletion)
            }

        }
    }

    @objc(purchasePackage:offering:signedDiscountTimestamp:completionBlock:)
    static func purchasePackage(_ packageIdentifier: String,
                                offeringIdentifier: String,
                                signedDiscountTimestamp: String?,
                                completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let hybridCompletion: (StoreTransaction?,
                               CustomerInfo?,
                               Error?,
                               Bool) -> Void = { transaction, customerInfo, error, userCancelled in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: ["userCancelled": userCancelled]))
            } else if let customerInfo = customerInfo,
                      let transaction = transaction {
                completion([
                    "customerInfo": customerInfo.dictionary,
                    "productIdentifier": transaction.sk1Transaction!.payment.productIdentifier
                ], nil)
            } else {
                let error = NSError(domain: RCPurchasesErrorCodeDomain,
                                    code: ErrorCode.unknownError.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: description])

                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            }
        }

        package(withIdentifier: packageIdentifier, offeringIdentifier: offeringIdentifier) { package in
            guard let package = package else {
                let error = productNotFoundError(description: "Couldn't find package", userCancelled: false)
                completion(nil, error)
                return
            }

            if let signedDiscountTimestamp = signedDiscountTimestamp {
                if #available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *) {
                    guard let promotionalOffer = self.promoOffersByTimestamp[signedDiscountTimestamp] else {
                        completion(nil, productNotFoundError(description: "Couldn't find discount.", userCancelled: false))
                        return
                    }
                    Purchases.shared.purchase(package: package,
                                              promotionalOffer: promotionalOffer,
                                              completion: hybridCompletion)
                    return
                }

            }

            Purchases.shared.purchase(package: package, completion: hybridCompletion)
        }

    }

    @objc(makeDeferredPurchase:completionBlock:)
    static func makeDeferredPurchase(_ startPurchase: StartPurchaseBlock,
                                     completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        startPurchase { transaction, customerInfo, error, userCancelled in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: ["userCancelled": userCancelled]))
            } else if let customerInfo = customerInfo,
                      let transaction = transaction {
                completion([
                    "customerInfo": customerInfo.dictionary,
                    "productIdentifier": transaction.sk1Transaction!.payment.productIdentifier
                ], nil)
            } else {
                let error = NSError(domain: RCPurchasesErrorCodeDomain,
                                    code: ErrorCode.unknownError.rawValue,
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
        Purchases.shared.logIn(appUserID) { customerInfo, created, error in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            } else if let customerInfo = customerInfo {
                completion([
                    "customerInfo": customerInfo.dictionary,
                    "created": created
                ], nil)
            } else {
                let error = NSError(domain: RCPurchasesErrorCodeDomain,
                                    code: ErrorCode.unknownError.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: description])

                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            }
        }
    }

    @objc(logOutWithCompletionBlock:)
    static func logOut(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.logOut(completion: customerInfoCompletionBlock(from: completion))
    }

    @objc(getCustomerInfoWithCompletionBlock:)
    static func customerInfo(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.getCustomerInfo(completion: customerInfoCompletionBlock(from: completion))
    }

}

// MARK: offerings and eligibility
@objc public extension CommonFunctionality {

    @objc(getOfferingsWithCompletionBlock:)
    static func getOfferings(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.getOfferings { offerings, error in
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
            Purchases.shared.checkTrialOrIntroDiscountEligibility(productIdentifiers: products) { eligibilityByProductId in
                completion(eligibilityByProductId.mapValues { [
                    "status": $0.status,
                    "description": $0.description
                ]
                })
            }
        }


    @objc static func getProductInfo(_ productIds: [String], completionBlock: @escaping([[String: Any]]) -> Void) {
        Purchases.shared.getProducts(productIds) { products in
            let productDictionaries = products
                .map { $0.sk1Product! }
                .map { $0.rc_dictionary }
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

            let paymentDiscountCompletion: (PromotionalOffer?, Error?) -> Void = { promotionalOffer, error in
                guard let promotionalOffer = promotionalOffer else {
                    if let error = error {
                        completion(nil, ErrorContainer(error: error, extraPayload: [:]))
                    } else {
                        let error = NSError(domain: RCPurchasesErrorCodeDomain,
                                            code: ErrorCode.unknownError.rawValue,
                                            userInfo: [NSLocalizedDescriptionKey: description])

                        completion(nil, ErrorContainer(error: error, extraPayload: [:]))
                    }
                    return
                }
                promoOffersByTimestamp["\(promotionalOffer.signedData.timestamp)"] = promotionalOffer
                completion(promotionalOffer.rc_dictionary, nil)
            }
            let storeProduct = StoreProduct(sk1Product: product)
            Purchases.shared.getPromotionalOffer(forProductDiscount: discountToUse,
                                                 product: storeProduct,
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
         Purchases.shared.setPushTokenString(pushToken)
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

    @available(*, deprecated, message: "Use the set<NetworkId> functions instead")
    @objc static func addAttributionData(_ data: [String: Any], network: Int, networkUserId: String) {
        // todo: clean up force cast after migration to v4
        Purchases.addAttributionData(data,
                                     from: AttributionNetwork(rawValue: network)!,
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

    static func customerInfoCompletionBlock(from block: @escaping ([String: Any]?, ErrorContainer?) -> Void)
    -> ((CustomerInfo?, Error?) -> Void) {
        return { customerInfo, error in
            if let error = error {
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])
                block(nil, errorContainer)
            } else if let customerInfo = customerInfo {
                block(customerInfo.dictionary, nil)
            } else {
                let error = NSError(domain: RCPurchasesErrorCodeDomain,
                                    code: ErrorCode.unknownError.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: description])

                block(nil, ErrorContainer(error: error, extraPayload: [:]))
            }
        }

    }

    static func product(with identifier: String, completion: @escaping (SKProduct?) -> Void) {
        Purchases.shared.getProducts([identifier]) { products in
            completion(products.first { $0.productIdentifier == identifier }?.sk1Product)
        }
    }

    static func productNotFoundError(description: String, userCancelled: Bool?) -> ErrorContainer {
        var extraPayload: [String: Any] = [:]
        if let userCancelled = userCancelled {
            extraPayload["userCancelled"] = userCancelled
        }

        let error = NSError(domain: RCPurchasesErrorCodeDomain,
                            code: ErrorCode.productNotAvailableForPurchaseError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: description])
        return ErrorContainer(error: error, extraPayload: extraPayload)
    }

    static func package(withIdentifier packageIdentifier: String,
                        offeringIdentifier: String,
                        completion: @escaping(Package?) -> Void) {
        Purchases.shared.getOfferings { offerings, error in
            let offering = offerings?.offering(identifier: offeringIdentifier)
            let package = offering?.package(identifier: packageIdentifier)
            completion(package)
        }
    }

    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *)
    static func discount(with identifier: String?, for product: SKProduct) -> StoreProductDiscount? {
        let storeProduct = StoreProduct(sk1Product: product)
        if identifier == nil {
            return storeProduct.discounts.first
        } else {
            return storeProduct.discounts.first { $0.offerIdentifier == identifier }
        }
    }

}
