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

//typedef void (^RCHybridResponseBlock)(NSDictionary * _Nullable, RCErrorContainer * _Nullable);
typealias HybridResponseBlock = ([String: Any]?, ErrorContainer?) -> Void

// todo: rename back to RCCommonFunctionality
@objc(RCCommonFunctionality2) public class CommonFunctionality: NSObject {

    @objc public static var proxyURLString: String?
    @objc public static var simulatesAskToBuyInSandbox: Bool = false
    @objc public static var appUserID: String { Purchases.shared.appUserID }

    private static var _discountsByProductIdentifier: Any? = nil
    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *)
    static var discountsByProductIdentifier: [String: SKPaymentDiscount]? {
        get {
            return _discountsByProductIdentifier as? [String: SKPaymentDiscount]
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

    @objc public static func addAttributionData(_ data: [String: Any], network: Int, networkUserId: String) {
        // todo: clean up force cast after migration to v4
        Purchases.addAttributionData(data,
                                     from: RCAttributionNetwork(rawValue: network)!,
                                     forNetworkUserId: networkUserId)
    }

    @objc public static func getProductInfo(_ productIds: [String], completionBlock: @escaping([[String: Any]]) -> Void) {
        Purchases.shared.products(productIds) { products in
            let productDictionaries = products.map { $0.rc_dictionary }
            completionBlock(productDictionaries)
        }
    }

    @objc(restoreTransactionsWithCompletionBlock:)
    public static func restoreTransactions(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        let purchaserInfoCompletion = purchaserInfoCompletionBlock(from: completion)
        Purchases.shared.restoreTransactions(purchaserInfoCompletion)
    }

    @objc(syncPurchasesWithCompletionBlock:)
    public static func syncPurchases(completion: (([String: Any]?, ErrorContainer?) -> Void)?) {
        if let completion = completion {
            let purchaserInfoCompletion = purchaserInfoCompletionBlock(from: completion)
            Purchases.shared.restoreTransactions(purchaserInfoCompletion)
        } else {
            Purchases.shared.restoreTransactions(nil)
        }
    }

    @objc(logInWithAppUserID:completionBlock:)
    public static func logIn(appUserID: String, completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.logIn(appUserID) { purchaserInfo, created, error in
            if let error = error {
                completion(nil, ErrorContainer(error: error, extraPayload: [:]))
            } else {
                completion([
                    "purchaserInfo": purchaserInfo?.dictionary ?? "<Purchaser Info Empty>",
                    "created": created
                ], nil)
            }
        }
    }

    @objc(logOutWithCompletionBlock:)
    public static func logOut(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.logOut(purchaserInfoCompletionBlock(from: completion))
    }

    @objc(createAlias:completionBlock:)
    public static func createAlias(newAppUserID: String, completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.createAlias(newAppUserID, purchaserInfoCompletionBlock(from: completion))
    }

    @objc(identify:completionBlock:)
    public static func identify(appUserID: String, completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.identify(appUserID, purchaserInfoCompletionBlock(from: completion))
    }

    @objc(resetWithCompletionBlock:)
    public static func reset(completion: @escaping ([String: Any]?, ErrorContainer?) -> Void) {
        Purchases.shared.reset(purchaserInfoCompletionBlock(from: completion))
    }

}

private extension CommonFunctionality {

    private static func purchaserInfoCompletionBlock(from hybridResponseBlock: @escaping ([String: Any]?, ErrorContainer?) -> Void)
    -> ((Purchases.PurchaserInfo?, Error?) -> Void) {
        return { purchaserInfo, error in
            if let error = error {
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])
                hybridResponseBlock(nil, errorContainer)
            } else if let purchaserInfo = purchaserInfo {
                hybridResponseBlock(purchaserInfo.dictionary, nil)
            } else {
                fatalError("got nil error and nil purchaserInfo")
            }
        }

    }

}
