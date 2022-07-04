//
//  NonSubscriptionTransaction+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by NachoSoto on 7/4/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

@objc public extension NonSubscriptionTransaction {

    var dictionary: [String: Any] {
        return [
            "revenueCatId": self.transactionIdentifier,
            "productId": self.productIdentifier,
            "purchaseDateMillis": self.purchaseDate.rc_millisecondsSince1970AsDouble(),
            "purchaseDate": self.purchaseDate.rc_formattedAsISO8601()
        ]
    }

}
