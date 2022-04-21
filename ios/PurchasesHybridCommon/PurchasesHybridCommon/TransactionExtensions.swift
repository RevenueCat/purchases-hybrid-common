//
//  TransactionExtensions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

@objc public extension StoreTransaction {

    @objc var dictionary: [String: Any] {
        let purchaseNSDate = purchaseDate as NSDate
        return [
            "revenueCatId": transactionIdentifier,
            "productId": productIdentifier,
            "purchaseDateMillis": purchaseNSDate.rc_millisecondsSince1970AsDouble(),
            "purchaseDate": purchaseNSDate.rc_formattedAsISO8601()
        ]
    }

}
