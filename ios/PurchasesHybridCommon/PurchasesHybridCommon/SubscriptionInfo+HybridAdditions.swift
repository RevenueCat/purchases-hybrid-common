//
//  EntitlementInfo+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

internal extension SubscriptionInfo {

    var dictionary: [String: Any] {
        var priceObject: [String: Any]? = nil
        if let priceCurrency = price?.currency, let priceAmount = price?.amount {
            priceObject = ["currency": priceCurrency, "amount": priceAmount]
        }
        return [
            "productIdentifier": productIdentifier,
            "purchaseDate": purchaseDate.rc_formattedAsISO8601(),
            "originalPurchaseDate": originalPurchaseDate?.rc_formattedAsISO8601() ?? NSNull(),
            "expiresDate": expiresDate?.rc_formattedAsISO8601() ?? NSNull(),
            "store": store.storeString,
            "isSandbox": isSandbox,
            "unsubscribeDetectedAt": unsubscribeDetectedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "billingIssuesDetectedAt": billingIssuesDetectedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "gracePeriodExpiresDate": billingIssuesDetectedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "ownershipType": ownershipType.ownershipTypeString,
            "periodType": periodType.periodTypeString,
            "refundedAt": refundedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "storeTransactionId": storeTransactionId ?? NSNull(),
            "price": priceObject ?? NSNull(),
            "isActive": isActive,
            "willRenew": willRenew,
        ]
    }

}
