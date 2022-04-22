//
//  EntitlementInfoExtensions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import Purchases

@objc public extension Purchases.EntitlementInfo {

    @objc var dictionary: [String: Any] {

        let latestPurchaseNSDate = latestPurchaseDate as NSDate
        let originalPurchaseNSDate = originalPurchaseDate as NSDate
        let expirationNSDate = expirationDate as? NSDate
        let unsubscribedDetectedAtNSDate = unsubscribeDetectedAt as? NSDate
        let billingIssueDetectedAtNSDate = billingIssueDetectedAt as? NSDate

        return [
            "identifier": identifier,
            "isActive": isActive,
            "willRenew": willRenew,
            "periodType": periodTypeString,
            "latestPurchaseDate": latestPurchaseNSDate.rc_formattedAsISO8601(),
            "latestPurchaseDateMillis": latestPurchaseNSDate.rc_millisecondsSince1970AsDouble(),
            "originalPurchaseDate": originalPurchaseNSDate.rc_formattedAsISO8601(),
            "originalPurchaseDateMillis": originalPurchaseNSDate.rc_millisecondsSince1970AsDouble(),
            "expirationDate": expirationNSDate?.rc_formattedAsISO8601() ?? NSNull(),
            "expirationDateMillis": expirationNSDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "store": storeString,
            "productIdentifier": productIdentifier,
            "isSandbox": isSandbox,
            "unsubscribedDetectedAt": unsubscribedDetectedAtNSDate?.rc_formattedAsISO8601() ?? NSNull(),
            "unsubscribedDetectedAtMillis": unsubscribedDetectedAtNSDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "billingIssueDetectedAt": billingIssueDetectedAtNSDate?.rc_formattedAsISO8601() ?? NSNull(),
            "billingIssueDetectedAtMillis": billingIssueDetectedAtNSDate?.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "ownershipType": ownershipTypeString
        ]
    }

}

private extension Purchases.EntitlementInfo {

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
        case .stripe:
            return "STRIPE"
        @unknown default:
            return "UNKNOWN_STORE"
        }
    }

}
