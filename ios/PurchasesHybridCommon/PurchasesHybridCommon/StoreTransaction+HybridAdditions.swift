//
//  StoreTransaction+HybridAdditions.swift
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
            "transactionIdentifier": self.transactionIdentifier,
            // Deprecated: Use transactionIdentifier in this map instead
            "revenueCatId": self.transactionIdentifier,
            "productIdentifier": self.productIdentifier,
            // Deprecated: Use productIdentifier in this map instead
            "productId": self.productIdentifier,
            "purchaseDateMillis": self.purchaseDate.rc_millisecondsSince1970AsDouble(),
            "purchaseDate": self.purchaseDate.rc_formattedAsISO8601()
        ]
    }

}
