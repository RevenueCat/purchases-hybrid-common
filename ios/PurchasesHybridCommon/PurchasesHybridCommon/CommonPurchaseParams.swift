//
//  CommonPurchaseParams.swift
//  PurchasesHybridCommon
//
//  Created by Antonio Rico Diez on 17/9/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import RevenueCat

enum PurchasableItem {
    case product(productIdentifier: String)
    case package(packageIdentifier: String)
}

struct CommonPurchaseParams {
    let purchasableItem: PurchasableItem
    let signedDiscountTimestamp: String?
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
            winBackOfferID: winBackOfferID,
            presentedOfferingContext: presentedOfferingContext
        )
    }

}
