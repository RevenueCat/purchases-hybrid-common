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

    var dictionary: [String: Any] {
        return [
            "revenueCatId": transactionIdentifier,
            "productId": productIdentifier,
            "purchaseDateMillis": purchaseDate.rc_millisecondsSince1970AsDouble(),
            "purchaseDate": purchaseDate.rc_formattedAsISO8601()
        ]
    }

}
