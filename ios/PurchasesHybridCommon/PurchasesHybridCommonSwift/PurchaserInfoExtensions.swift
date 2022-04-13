//
//  PurchaserInfoExtensions.swift
//  PurchasesHybridCommonSwift
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import Purchases

@objc public extension Purchases.PurchaserInfo {

    @objc var dictionary: [String: Any] {

        let sortedProductIdentifiers = allPurchasedProductIdentifiers.sorted()

        var allExpirations: [String: Any] = [:]
        var allExpirationsMillis: [String: Any] = [:]

        var allPurchases: [String: Any] = [:]
        var allPurchasesMillis: [String: Any] = [:]

        for identifier in sortedProductIdentifiers {
            let expirationDate = expirationDate(forProductIdentifier:identifier)?.nsDate
            allExpirations[identifier] = expirationDate?.rc_formattedAsISO8601 ?? NSNull()
            allExpirationsMillis[identifier] = expirationDate?.rc_millisecondsSince1970AsDouble() ?? NSNull()

            let purchaseDate = purchaseDate(forProductIdentifier: identifier)?.nsDate
            allPurchases[identifier] = purchaseDate?.rc_formattedAsISO8601() ?? NSNull()
            allPurchasesMillis[identifier] = purchaseDate?.rc_millisecondsSince1970AsDouble() ?? NSNull()
        }


        return [
            "entitlements": entitlements.dictionary,
            "activeSubscriptions": Array(activeSubscriptions),
            "allPurchasedProductIdentifiers": allPurchasedProductIdentifiers,
            "latestExpirationDate": latestExpirationDate?.nsDate.rc_formattedAsISO8601() ?? NSNull(),
            "latestExpirationDateMillis": latestExpirationDate?.nsDate.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "firstSeen": firstSeen.nsDate.rc_formattedAsISO8601(),
            "firstSeenMillis": firstSeen.nsDate.rc_millisecondsSince1970AsDouble(),
            "originalAppUserId": originalAppUserId,
            "requestDate": requestDate?.nsDate.rc_formattedAsISO8601() ?? NSNull(),
            "requestDateMillis": requestDate?.nsDate.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "allExpirationDates": allExpirations,
            "allExpirationDatesMillis": allExpirationsMillis,
            "allPurchaseDates": allPurchases,
            "allPurchaseDatesMillis": allPurchasesMillis,
            "originalApplicationVersion": originalApplicationVersion ?? NSNull(),
            "originalPurchaseDate": originalPurchaseDate?.nsDate.rc_formattedAsISO8601() ?? NSNull(),
            "originalPurchaseDateMillis": originalPurchaseDate?.nsDate.rc_millisecondsSince1970AsDouble() ?? NSNull(),
            "managementURL": managementURL ?? NSNull(),
            "nonSubscriptionTransactions": nonSubscriptionTransactions.map { $0.dictionary },
        ]
    }

}

private extension Date {

    var nsDate: NSDate {
        return self as NSDate
    }

}
