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

    typealias InstanceType = PurchasesType & PurchasesSwiftType

    static var sharedInstance: InstanceType {
        get {
            guard let purchases = Self._sharedInstance else {
                fatalError("Purchases has not been configured. Please configure the SDK before calling this method")
            }

            return purchases
        }
        set {
            Self._sharedInstance = newValue
        }
    }

    private static var _sharedInstance: InstanceType?

    // MARK: properties and configuration

    @objc public static var simulatesAskToBuyInSandbox: Bool = false
    @objc public static var appUserID: String { Self.sharedInstance.appUserID }
    @objc public static var isAnonymous: Bool { Self.sharedInstance.isAnonymous }
    @objc public static var hybridCommonVersion: String { Constants.hybridCommonVersion }

    @objc public static var proxyURLString: String? {
        get { Purchases.proxyURL?.absoluteString }
        set {
            if let value = newValue {
                let url: URL?
                // Starting with iOS 17, URL(string:) returns a non-nil value from invalid URLs. 
                // So we use a new method to get the old behavior.
                // Since the new method isn't recognized by older Xcodes, we use Swift 5.9 as a proxy for Xcode 15+.
                // https://developer.apple.com/documentation/xcode-release-notes/xcode-15_0-release-notes
                #if swift(>=5.9)
                if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                    url = URL(string: value, encodingInvalidCharacters: false)
                } else {
                    url = URL(string: value)
                }
                #else
                url = URL(string: value)
                #endif
                guard let proxyURL = url else {
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
        Self.sharedInstance.allowSharingAppStoreAccount = allowSharingStoreAccount
    }

    @available(*, deprecated, message: "Use setLogLevel instead")
    @objc public static func setDebugLogsEnabled(_ enabled: Bool) {
        Purchases.logLevel = enabled ? .debug : .info
    }

    @objc public static func setLogLevel(_ level: String) {
        guard let level = LogLevel.levelsByDescription[level] else {
            NSLog("Unrecognized log level '\(level)'")
            return
        }

        Purchases.logLevel = level
    }

    /**
     * Sets a log handler and forwards all logs to completion function.
     *
     * - Parameter onLogReceived: Gets a map with two keys: `logLevel` (``LogLevel``  name uppercased), and `message` (the log message)
     */
    @objc public static func setLogHander(onLogReceived: @escaping ([String: String]) -> Void) {
        Purchases.logHandler = { logLevel, message in
            let logDetails = [
                "logLevel": logLevel.description,
                "message": message
            ]
            onLogReceived(logDetails)
        }
    }

    @available(iOS 14.3, macOS 11.1, macCatalyst 14.3, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @objc public static func enableAdServicesAttributionTokenCollection() {
        Self.sharedInstance.attribution.enableAdServicesAttributionTokenCollection()
    }

    @objc public static func setPurchasesAreCompletedBy(_ purchasesAreCompletedBy: String) {
        if let actualPurchasesAreCompletedBy = PurchasesAreCompletedBy(name: purchasesAreCompletedBy) {
            Self.sharedInstance.purchasesAreCompletedBy = actualPurchasesAreCompletedBy
        }
    }

    @objc public static func invalidateCustomerInfoCache() {
        Self.sharedInstance.invalidateCustomerInfoCache()
    }

#if os(iOS)
    @available(iOS 14.0, *)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(macCatalyst, unavailable)
    @objc public static func presentCodeRedemptionSheet() {
        Self.sharedInstance.presentCodeRedemptionSheet()
    }
#endif

    @objc public static func canMakePaymentsWithFeatures(_ features: [Int]) -> Bool {
        // Features are for Google Play only, so we ignore them for iOS.
        // See https://sdk.revenuecat.com/android/5.1.1/purchases/com.revenuecat.purchases/-purchases/-companion/can-make-payments.html
        return Purchases.canMakePayments()
    }
}

// MARK: Refund request
@objc public extension CommonFunctionality {

#if os(iOS)
    @available(iOS 15.0, *)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @objc(beginRefundRequestProductId:completionBlock:)
    static func beginRefundRequest(productId: String,
                                   completion: @escaping (ErrorContainer?) -> Void) {
        Self.sharedInstance.beginRefundRequest(forProduct: productId) { result in
            Self.processRefundRequestResultWithCompletion(refundRequestResult: result, completion: completion)
        }
    }

    @available(iOS 15.0, *)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @objc(beginRefundRequestEntitlementId:completionBlock:)
    static func beginRefundRequest(entitlementId: String,
                                   completion: @escaping (ErrorContainer?) -> Void) {
        Self.sharedInstance.beginRefundRequest(forEntitlement: entitlementId) { result in
            Self.processRefundRequestResultWithCompletion(refundRequestResult: result, completion: completion)
        }
    }

    @available(iOS 15.0, *)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @objc(beginRefundRequestForActiveEntitlementCompletion:)
    static func beginRefundRequestForActiveEntitlement(completion: @escaping (ErrorContainer?) -> Void) {
        Self.sharedInstance.beginRefundRequestForActiveEntitlement { result in
            Self.processRefundRequestResultWithCompletion(refundRequestResult: result, completion: completion)
        }
    }
#endif

}

// MARK: In app messages
@objc public extension CommonFunctionality {

#if os(iOS) || targetEnvironment(macCatalyst) || VISION_OS
    @available(iOS 16.0, *)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @objc(showStoreMessagesCompletion:)
    static func showStoreMessages(completion: @escaping () -> Void) {
        _ = Task<Void, Never> {
            await Self.sharedInstance.showStoreMessages(for: Set(StoreMessageType.allCases))
            completion()
        }
    }

    @available(iOS 16.0, *)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @objc(showStoreMessagesForTypes:completion:)
    static func showStoreMessages(forRawValues rawValues: Set<NSNumber>,
                                  completion: @escaping () -> Void) {
        let storeMessageTypes = rawValues.compactMap { number in
            StoreMessageType(rawValue: number.intValue)
        }
        _ = Task<Void, Never> {
            await Self.sharedInstance.showStoreMessages(for: Set(storeMessageTypes))
            completion()
        }
    }
#endif

}

// MARK: purchasing and restoring
@objc public extension CommonFunctionality {

    @objc(restorePurchasesWithCompletionBlock:)
    static func restorePurchases(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let customerInfoCompletion = customerInfoCompletionBlock(from: completion)
        Self.sharedInstance.restorePurchases(completion: customerInfoCompletion)
    }

    @objc(syncPurchasesWithCompletionBlock:)
    static func syncPurchases(completion: (([String: Any]?, ErrorContainer?) -> Void)?) {
        if let completion = completion {
            let customerInfoCompletion = customerInfoCompletionBlock(from: completion)
            Self.sharedInstance.syncPurchases(completion: customerInfoCompletion)
        } else {
            Self.sharedInstance.syncPurchases(completion: nil)
        }
    }

    @objc(purchaseProduct:signedDiscountTimestamp:completionBlock:)
    static func purchase(product productIdentifier: String,
                         signedDiscountTimestamp: String?,
                         completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let hybridCompletion = Self.createPurchaseCompletionBlock(completion: completion)

        self.product(with: productIdentifier) { storeProduct in
            guard let storeProduct = storeProduct else {
                completion(nil, productNotFoundError(description: "Couldn't find product.", userCancelled: false))
                return
            }

            if let signedDiscountTimestamp = signedDiscountTimestamp {
                if #available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *) {
                    guard let promotionalOffer = self.promoOffersByTimestamp[signedDiscountTimestamp] else {
                        completion(nil, productNotFoundError(description: "Couldn't find discount.", userCancelled: false))
                        return
                    }
                    Self.sharedInstance.purchase(product: storeProduct,
                                              promotionalOffer: promotionalOffer,
                                              completion: hybridCompletion)
                    return
                }

            }

            Self.sharedInstance.purchase(product: storeProduct, completion: hybridCompletion)
        }
    }

    @objc(purchasePackage:presentedOfferingContext:signedDiscountTimestamp:completionBlock:)
    static func purchase(package packageIdentifier: String,
                         presentedOfferingContext: [String: Any],
                         signedDiscountTimestamp: String?,
                         completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let hybridCompletion = Self.createPurchaseCompletionBlock(completion: completion)

        Self.package(
            withIdentifier: packageIdentifier,
            presentedOfferingContext: Self.toPresentedOfferingContext(presentedOfferingContext: presentedOfferingContext)
        ) { package in
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
                    Self.sharedInstance.purchase(package: package,
                                                 promotionalOffer: promotionalOffer,
                                                 completion: hybridCompletion)
                    return
                }

            }

            Self.sharedInstance.purchase(package: package, completion: hybridCompletion)
        }

    }

    @objc(makeDeferredPurchase:completionBlock:)
    static func makeDeferredPurchase(_ startPurchase: StartPurchaseBlock,
                                     completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        startPurchase(Self.createPurchaseCompletionBlock(completion: completion))
    }

    private static func createPurchaseCompletionBlock(
        completion: @escaping ([String: Any]?, ErrorContainer?) -> Void
    ) -> @Sendable (StoreTransaction?,
                    CustomerInfo?,
                    Error?,
                    Bool) -> Void {
        return { transaction, customerInfo, error, userCancelled in
            if let error = error {
                completion(nil, Self.createErrorContainer(error: error, userCancelled: userCancelled))
            } else if let customerInfo = customerInfo,
                      let transaction = transaction {
                completion([
                    "customerInfo": customerInfo.dictionary,
                    "productIdentifier": transaction.productIdentifier,
                    "transaction": transaction.dictionary
                ], nil)
            } else {
                completion(
                    nil,
                    ErrorContainer(error: ErrorCode.unknownError as NSError, extraPayload: [:])
                )
            }
        }
    }

}

// MARK: identity
@objc public extension CommonFunctionality {

    @objc(logInWithAppUserID:completionBlock:)
    static func logIn(appUserID: String, completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Self.sharedInstance.logIn(appUserID) { customerInfo, created, error in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            } else if let customerInfo = customerInfo {
                completion([
                    "customerInfo": customerInfo.dictionary,
                    "created": created
                ], nil)
            } else {
                let error = ErrorCode.unknownError as NSError
                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            }
        }
    }

    @objc(logOutWithCompletionBlock:)
    static func logOut(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Self.sharedInstance.logOut(completion: customerInfoCompletionBlock(from: completion))
    }

    @objc(getCustomerInfoWithCompletionBlock:)
    static func customerInfo(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Self.customerInfo(fetchPolicy: .default, completion: completion)
    }

    internal static func customerInfo(
        fetchPolicy: CacheFetchPolicy,
        completion: @escaping ([String: Any]?, ErrorContainer?) -> Void
    ) {
        Self.sharedInstance.getCustomerInfo(fetchPolicy: fetchPolicy,
                                         completion: customerInfoCompletionBlock(from: completion))
    }

}

// MARK: offerings and eligibility
@objc public extension CommonFunctionality {

    @objc(getOfferingsWithCompletionBlock:)
    static func getOfferings(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Self.sharedInstance.getOfferings { offerings, error in
            if let error = error {
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])
                completion(nil, errorContainer)
            } else {
                completion(offerings?.dictionary, nil)
            }
        }
    }

    @objc(getCurrentOfferingForPlacement:completionBlock:)
    static func getCurrentOffering(
        forPlacement placementIdentifier: String,
        completion: @escaping ([String: Any]?, ErrorContainer?) -> Void
    ) {
        Self.sharedInstance.getOfferings { offerings, error in
            if let error = error {
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])
                completion(nil, errorContainer)
            } else {
                let offering = offerings?.currentOffering(forPlacement: placementIdentifier)
                let dict = offering?.dictionary
                completion(dict, nil)
            }
        }
    }

    @objc(syncAttributesAndOfferingsIfNeededWithCompletionBlock:)
    static func syncAttributesAndOfferingsIfNeeded(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Self.sharedInstance.syncAttributesAndOfferingsIfNeeded { offerings, error in
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
            Self.sharedInstance.checkTrialOrIntroDiscountEligibility(productIdentifiers: products) { eligibilityByProductId in
                completion(eligibilityByProductId.mapValues { [
                    "status": $0.status.rawValue,
                    "description": $0.description
                ] as [String: Any]
                })
            }
        }

    @objc static func getProductInfo(_ productIds: [String], completionBlock: @escaping([[String: Any]]) -> Void) {
        Self.sharedInstance.getProducts(productIds) { products in
            let productDictionaries = products
                .map { $0.rc_dictionary }
            completionBlock(productDictionaries)
        }
    }

    @objc(promotionalOfferForProductIdentifier:discount:completionBlock:)
    static func promotionalOffer(for productIdentifier: String,
                                 discountIdentifier: String?,
                                 completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        guard #available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *) else {
            completion(
                nil,
                Self.createErrorContainer(error: ErrorCode.unsupportedError)
            )
            return
        }

        product(with: productIdentifier) { storeProduct in
            guard let storeProduct = storeProduct else {
                completion(nil, productNotFoundError(description: "Couldn't find product", userCancelled: false))
                return
            }

            guard let discountToUse = self.discount(with: discountIdentifier, for: storeProduct) else {
                completion(nil, productNotFoundError(description: "Couldn't find discount", userCancelled: false))
                return
            }

            let promotionalOfferCompletion: (PromotionalOffer?, Error?) -> Void = { promotionalOffer, error in
                guard let promotionalOffer = promotionalOffer else {
                    completion(
                        nil,
                        ErrorContainer(error: error ?? ErrorCode.unknownError as NSError,
                                       extraPayload: [:])
                    )
                    return
                }
                promoOffersByTimestamp["\(promotionalOffer.signedData.timestamp)"] = promotionalOffer
                completion(promotionalOffer.rc_dictionary, nil)
            }

            Self.sharedInstance.getPromotionalOffer(forProductDiscount: discountToUse,
                                                 product: storeProduct,
                                                 completion: promotionalOfferCompletion)
        }
    }

}

// MARK: StoreKit 2 Observer Mode
@objc public extension CommonFunctionality {

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    @objc(recordPurchaseForProductID:completion:)
    static func recordPurchase(productID: String, completion: (([String: Any]?, ErrorContainer?) -> Void)?) {
        _ = Task<Void, Never> {
            let result = await StoreKit.Transaction.latest(for: productID)
            if let result = result {
                do {
                    let transaction = try await Self.sharedInstance.recordPurchase(.success(result))
                    completion?(transaction?.dictionary, nil)
                } catch {
                    completion?(nil, ErrorContainer(error: error, extraPayload: [:]))
                }
            } else {
                completion?(nil, transactionNotFoundError(
                    description: "Couldn't find transaction for product ID '\(productID)'.",
                    userCancelled: false
                ))
            }
        }
    }

}

// MARK: Subscriber attributes
@objc public extension CommonFunctionality {

    @objc static func setAttributes(_ attributes: [String: Any]) {
        Self.sharedInstance.attribution.setAttributes(attributes.mapValues { $0 as? String ?? "" })
    }

    @objc static func setEmail(_ email: String?) {
        Self.sharedInstance.attribution.setEmail(email)
    }

    @objc static func setPhoneNumber(_ phoneNumber: String?) {
        Self.sharedInstance.attribution.setPhoneNumber(phoneNumber)
    }

    @objc static func setDisplayName(_ displayName: String?) {
        Self.sharedInstance.attribution.setDisplayName(displayName)
    }

    @objc static func setPushToken(_ pushToken: String?) {
         Self.sharedInstance.attribution.setPushTokenString(pushToken)
    }

}

// MARK: Attribution IDs
@objc public extension CommonFunctionality {

    @objc static func collectDeviceIdentifiers() {
        Self.sharedInstance.attribution.collectDeviceIdentifiers()
    }
    @objc static func setAdjustID(_ adjustID: String?) {
        Self.sharedInstance.attribution.setAdjustID(adjustID)
    }
    @objc static func setCleverTapID(_ cleverTapID: String?) {
        Self.sharedInstance.attribution.setCleverTapID(cleverTapID)
    }
    @objc static func setAppsflyerID(_ appsflyerID: String?) {
        Self.sharedInstance.attribution.setAppsflyerID(appsflyerID)
    }
    @objc static func setFBAnonymousID(_ fbAnonymousID: String?) {
        Self.sharedInstance.attribution.setFBAnonymousID(fbAnonymousID)
    }
    @objc static func setMparticleID(_ mParticleID: String?) {
        Self.sharedInstance.attribution.setMparticleID(mParticleID)
    }
    @objc static func setMixpanelDistinctID(_ mixpanelDistinctID: String?) {
        Self.sharedInstance.attribution.setMixpanelDistinctID(mixpanelDistinctID)
    }
    @objc static func setFirebaseAppInstanceID(_ firebaseAppInstanceID: String?) {
        Self.sharedInstance.attribution.setFirebaseAppInstanceID(firebaseAppInstanceID)
    }
    @objc static func setOnesignalID(_ onesignalID: String?) {
        Self.sharedInstance.attribution.setOnesignalID(onesignalID)
    }
    @objc static func setOnesignalUserID(_ onesignalUserID: String?) {
        Self.sharedInstance.attribution.setOnesignalUserID(onesignalUserID)
    }
    @objc static func setAirshipChannelID(_ airshipChannelID: String?) {
        Self.sharedInstance.attribution.setAirshipChannelID(airshipChannelID)
    }

}

// MARK: Campaign parameters
@objc public extension CommonFunctionality {

    @objc static func setMediaSource(_ mediaSource: String?) {
        Self.sharedInstance.attribution.setMediaSource(mediaSource)
    }
    @objc static func setCampaign(_ campaign: String?) {
        Self.sharedInstance.attribution.setCampaign(campaign)
    }
    @objc static func setAdGroup(_ adGroup: String?) {
        Self.sharedInstance.attribution.setAdGroup(adGroup)
    }
    @objc static func setAd(_ ad: String?) {
        Self.sharedInstance.attribution.setAd(ad)
    }
    @objc static func setKeyword(_ keyword: String?) {
        Self.sharedInstance.attribution.setKeyword(keyword)
    }
    @objc static func setCreative(_ creative: String?) {
        Self.sharedInstance.attribution.setCreative(creative)
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
                block(nil, ErrorContainer(error: ErrorCode.unknownError as NSError, extraPayload: [:]))
            }
        }

    }

    static func product(with identifier: String, completion: @escaping (StoreProduct?) -> Void) {
        Self.sharedInstance.getProducts([identifier]) { products in
            completion(products.first { $0.productIdentifier == identifier })
        }
    }

    static func productNotFoundError(description: String, userCancelled: Bool?) -> ErrorContainer {
        let error = NSError(domain: ErrorCode.errorDomain,
                            code: ErrorCode.productNotAvailableForPurchaseError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: description])
        return Self.createErrorContainer(error: error, userCancelled: userCancelled)
    }

    static func toPresentedOfferingContext(presentedOfferingContext: [String: Any?]?) -> PresentedOfferingContext? {
        guard let presentedOfferingContext, let offeringIdentifier = presentedOfferingContext["offeringIdentifier"] as? String else {
            return nil
        }

        let placementIdentifier = presentedOfferingContext["placementIdentifier"] as? String

        let targetingContext: PresentedOfferingContext.TargetingContext?

        if let dict = presentedOfferingContext["targetingContext"] as? [String: Any?],
            let revision = dict["revision"] as? Int,
            let ruleId = dict["ruleId"] as? String {
            targetingContext = .init(revision: revision, ruleId: ruleId)
        } else {
            targetingContext = nil
        }

        return PresentedOfferingContext(
            offeringIdentifier: offeringIdentifier,
            placementIdentifier: placementIdentifier,
            targetingContext: targetingContext
        )
    }

    static func package(withIdentifier packageIdentifier: String,
                        presentedOfferingContext: PresentedOfferingContext?,
                        completion: @escaping(Package?) -> Void) {
        guard let presentedOfferingContext else {
            return completion(nil)
        }

        Self.sharedInstance.getOfferings { offerings, error in
            let offering = offerings?.offering(identifier: presentedOfferingContext.offeringIdentifier)
            let foundPackage = offering?.package(identifier: packageIdentifier)

            let package = foundPackage.flatMap { pkg in
                Package(
                    identifier: pkg.identifier,
                    packageType: pkg.packageType,
                    storeProduct: pkg.storeProduct,
                    presentedOfferingContext: presentedOfferingContext
                )
            }

            completion(package)
        }
    }

    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *)
    static func discount(with identifier: String?, for product: StoreProduct) -> StoreProductDiscount? {
        if identifier == nil {
            return product.discounts.first
        } else {
            return product.discounts.first { $0.offerIdentifier == identifier }
        }
    }

    static func transactionNotFoundError(description: String, userCancelled: Bool?) -> ErrorContainer {
        let error = NSError(domain: ErrorCode.errorDomain,
                            code: ErrorCode.unknownError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: description])
        return Self.createErrorContainer(error: error, userCancelled: userCancelled)
    }

    static func processRefundRequestResultWithCompletion(
        refundRequestResult: Result<RefundRequestStatus, PublicError>,
        completion: @escaping (ErrorContainer?) -> Void
    ) {
        switch refundRequestResult {
        case let .success(refundRequestStatus):
            switch refundRequestStatus {
            case .success:
                completion(nil)
            case .userCancelled:
                completion(Self.refundRequestError(description: "User cancelled refund request.", userCancelled: true))
            case .error:
                completion(Self.refundRequestError(description: "Error during refund request."))
            }
        case let .failure(error):
            completion(ErrorContainer(error: error, extraPayload: [:]))
        }
    }

    static func refundRequestError(description: String, userCancelled: Bool? = nil) -> ErrorContainer {
        let error = NSError(domain: ErrorCode.errorDomain,
                            code: ErrorCode.beginRefundRequestError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: description])
        return Self.createErrorContainer(error: error, userCancelled: userCancelled)
    }

    static func createErrorContainer(error: Error, userCancelled: Bool? = nil) -> ErrorContainer {
        var extraPayload: [String: Any] = [:]
        if let userCancelled = userCancelled {
            extraPayload["userCancelled"] = userCancelled
        }

        return ErrorContainer(error: error, extraPayload: extraPayload)
    }

}

// MARK: - Encoding

@objc public extension CommonFunctionality {

    // Note: see https://github.com/RevenueCat/purchases-hybrid-common/pull/485
    // `CustomerInfo.dictionary` can't be made an `@objc public` method while supporting iOS < 13.0
    @objc(encodeCustomerInfo:)
    static func encode(customerInfo: CustomerInfo) -> [String: Any] {
        return customerInfo.dictionary
    }

}
