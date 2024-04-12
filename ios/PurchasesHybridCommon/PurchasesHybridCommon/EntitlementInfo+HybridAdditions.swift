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
        let verificationResult: VerificationResult
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *) {
            verificationResult = verification
        } else {
            verificationResult = .notRequested
        }
        return [
            "identifier": identifier,
            "isActive": isActive,
            "willRenew": willRenew,
            "periodType": periodTypeString,
            "latestPurchaseDate": latestPurchaseDate?.rc_formattedAsISO8601() ?? NSNull(),
            "latestPurchaseDateMillis": latestPurchaseDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "originalPurchaseDate": originalPurchaseDate?.rc_formattedAsISO8601() ?? NSNull(),
            "originalPurchaseDateMillis": originalPurchaseDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "expirationDate": expirationDate?.rc_formattedAsISO8601() ?? NSNull(),
            "expirationDateMillis": expirationDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "store": storeString,
            "productIdentifier": productIdentifier,
            "productPlanIdentifier": productPlanIdentifier ?? NSNull(),
            "isSandbox": isSandbox,
            "unsubscribeDetectedAt": unsubscribeDetectedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "unsubscribeDetectedAtMillis": unsubscribeDetectedAt?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "billingIssueDetectedAt": billingIssueDetectedAt?.rc_formattedAsISO8601() ?? NSNull(),
            "billingIssueDetectedAtMillis": billingIssueDetectedAt?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "ownershipType": ownershipTypeString,
            "verification": verificationResult.name
        ]
    }

}

private extension EntitlementInfo {

    var periodTypeString: String {
        switch periodType {
        case .intro:
            return "INTRO"
        case .normal:
            return "NORMAL"
        case .trial:
            return "TRIAL"
        @unknown default:
            return "UNKNOWN"
        }
    }

    var ownershipTypeString: String {
        switch ownershipType {
        case .familyShared:
            return "FAMILY_SHARED"
        case .unknown:
            return "UNKNOWN"
        case .purchased:
            return "PURCHASED"
        @unknown default:
            return "UNKNOWN"
        }
    }

    var storeString: String {
        switch store {
        case .appStore:
            return "APP_STORE"
        case .macAppStore:
            return "MAC_APP_STORE"
        case .playStore:
            return "PLAY_STORE"
        case .promotional:
            return "PROMOTIONAL"
        case .unknownStore:
            return "UNKNOWN_STORE"
        case .amazon:
            return "AMAZON"
        case .stripe:
            return "STRIPE"
        case .rcBilling:
            return "RC_BILLING"
        case .external:
            return "EXTERNAL"
        @unknown default:
            return "UNKNOWN_STORE"
        }
    }

}
