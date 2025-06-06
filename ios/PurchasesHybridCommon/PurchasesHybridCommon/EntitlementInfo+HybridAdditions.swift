//
//  EntitlementInfo+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

internal extension EntitlementInfo {

    var dictionary: [String: Any] {
        return [
            "identifier": identifier,
            "isActive": isActive,
            "willRenew": willRenew,
            "periodType": periodType.periodTypeString,
            "latestPurchaseDate": latestPurchaseDate?.rc_formattedAsISO8601() ?? NSNull(),
            "latestPurchaseDateMillis": latestPurchaseDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "originalPurchaseDate": originalPurchaseDate?.rc_formattedAsISO8601() ?? NSNull(),
            "originalPurchaseDateMillis": originalPurchaseDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "expirationDate": expirationDate?.rc_formattedAsISO8601() ?? NSNull(),
            "expirationDateMillis": expirationDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "store": store.storeString,
            "productIdentifier": productIdentifier,
            "productPlanIdentifier": productPlanIdentifier ?? NSNull(),
            "isSandbox": isSandbox,
            "unsubscribeDetectedAt": unsubscribeDetectedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "unsubscribeDetectedAtMillis": unsubscribeDetectedAt?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "billingIssueDetectedAt": billingIssueDetectedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "billingIssueDetectedAtMillis": billingIssueDetectedAt?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "ownershipType": ownershipType.ownershipTypeString,
            "verification": verification.name
        ]
    }

}
