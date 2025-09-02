//
//  SubscriptionInfo+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Toni Rico on 3/3/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

internal extension SubscriptionInfo {

    var dictionary: [String: Any] {
        var priceObject: [String: Any]? = nil
        if let priceCurrency = price?.currency, let priceAmount = price?.amount {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = .autoupdatingCurrent
            formatter.currencyCode = priceCurrency
            let formattedPrice = formatter.string(from: NSDecimalNumber(decimal: Decimal(priceAmount))) ?? "\(priceAmount) \(priceCurrency)"
            
            priceObject = [
                "currency": priceCurrency,
                "amount": priceAmount,
                "formatted": formattedPrice
            ]
        }
        
        return [
            "productIdentifier": productIdentifier,
            "purchaseDate": purchaseDate.rc_formattedAsISO8601(),
            "purchaseDateMillis": purchaseDate.rc_millisecondsSince1970AsDouble(),
            "originalPurchaseDate": originalPurchaseDate?.rc_formattedAsISO8601() ?? NSNull(),
            "originalPurchaseDateMillis": originalPurchaseDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "expiresDate": expiresDate?.rc_formattedAsISO8601() ?? NSNull(),
            "expiresDateMillis": expiresDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "store": store.storeString,
            "isSandbox": isSandbox,
            "unsubscribeDetectedAt": unsubscribeDetectedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "unsubscribeDetectedAtMillis": unsubscribeDetectedAt?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "billingIssuesDetectedAt": billingIssuesDetectedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "billingIssuesDetectedAtMillis": billingIssuesDetectedAt?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "gracePeriodExpiresDate": gracePeriodExpiresDate?.rc_formattedAsISO8601() ?? NSNull(),
            "gracePeriodExpiresDateMillis": gracePeriodExpiresDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "ownershipType": ownershipType.ownershipTypeString,
            "periodType": periodType.periodTypeString,
            "refundedAt": refundedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "refundedAtMillis": refundedAt?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "storeTransactionId": storeTransactionId ?? NSNull(),
            "autoResumeDate": NSNull(),
            "autoResumeDateMillis": NSNull(),
            "productPlanIdentifier": NSNull(),
            "price": priceObject ?? NSNull(),
            "managementURL": managementURL?.absoluteString ?? NSNull(),
            "isActive": isActive,
            "willRenew": willRenew,
        ]
    }

}
