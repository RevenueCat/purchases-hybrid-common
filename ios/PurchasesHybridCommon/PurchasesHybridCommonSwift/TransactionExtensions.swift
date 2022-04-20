//
//  TransactionExtensions.swift
//  PurchasesHybridCommonSwift
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import Purchases
import PurchasesCoreSwift

@objc public extension Purchases.Transaction {

    @objc var dictionary: [String: Any] {
        let purchaseNSDate = purchaseDate as NSDate
        return [
            "revenueCatId": revenueCatId,
            "productId": productId,
            "purchaseDateMillis": purchaseNSDate.rc_millisecondsSince1970AsDouble(),
            "purchaseDate": purchaseNSDate.rc_formattedAsISO8601()
        ]
    }

}
