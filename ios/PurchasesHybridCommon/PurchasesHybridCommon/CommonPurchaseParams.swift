//
//  CommonPurchaseParams.swift
//  PurchasesHybridCommon
//
//  Created by Antonio Rico Diez on 17/9/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

enum PurchasableItem {
    case product(productIdentifier: String)
    case package(packageIdentifier: String)
}

struct CommonPurchaseParams {
    let purchasableItem: PurchasableItem
    let signedDiscountTimestamp: String?
    let introductoryOfferEligibilityJWS: String?
    let winBackOfferID: String?
    let presentedOfferingContext: [String: Any]?
}

extension CommonFunctionality {

    static func validatePurchaseParams(_ options: [String: Any]) throws -> CommonPurchaseParams {
        let packageIdentifier = options["packageIdentifier"] as? String
        let productIdentifier = options["productIdentifier"] as? String

        let presentedOfferingContext = options["presentedOfferingContext"] as? [String: Any]
        let signedDiscountTimestamp = options["signedDiscountTimestamp"] as? String
        let winBackOfferID = options["winBackOfferID"] as? String

        let introductoryOfferEligibilityJWS: String?
        if let value = options["introductoryOfferEligibilityJWS"], !(value is NSNull) {
            guard let jws = value as? String, !jws.isEmpty else {
                throw PublicError(domain: ErrorCode.errorDomain, code: ErrorCode.purchaseInvalidError.rawValue,
                                  userInfo: [NSLocalizedDescriptionKey:
                                                "introductoryOfferEligibilityJWS must be a non-empty string."])
            }
            guard signedDiscountTimestamp == nil, winBackOfferID == nil else {
                throw PublicError(domain: ErrorCode.errorDomain, code: ErrorCode.purchaseInvalidError.rawValue,
                                  userInfo: [NSLocalizedDescriptionKey:
                                                "introductoryOfferEligibilityJWS cannot be combined with promotional or win-back offers."])
            }
            introductoryOfferEligibilityJWS = jws
        } else {
            introductoryOfferEligibilityJWS = nil
        }

        let purchasableItem: PurchasableItem

        if let packageIdentifier = packageIdentifier {
            purchasableItem = .package(packageIdentifier: packageIdentifier)
        } else if let productIdentifier = productIdentifier {
            purchasableItem = .product(productIdentifier: productIdentifier)
        } else {
            throw PublicError(domain: ErrorCode.errorDomain,
                              code: ErrorCode.purchaseInvalidError.rawValue)
        }

        return CommonPurchaseParams(
            purchasableItem: purchasableItem,
            signedDiscountTimestamp: signedDiscountTimestamp,
            introductoryOfferEligibilityJWS: introductoryOfferEligibilityJWS,
            winBackOfferID: winBackOfferID,
            presentedOfferingContext: presentedOfferingContext
        )
    }

}
