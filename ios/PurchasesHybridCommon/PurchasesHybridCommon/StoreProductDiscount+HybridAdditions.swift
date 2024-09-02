//
//  SKProductDiscount+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import StoreKit
import RevenueCat

@objc public extension StoreProductDiscount {
    
    // Re-exports price property with a different name to avoid recursion.

    @objc var priceAmount: NSDecimalNumber {
        return self.priceDecimalNumber
    }

}

internal extension StoreProductDiscount {

    var rc_currencyCode: String? {
        return currencyCode
    }

    var rc_dictionary: [String: Any] {

        var dictionary: [String: Any] = [
            "price": price,
            "priceString": localizedPriceString,
            "period": StoreProduct.rc_normalized(subscriptionPeriod: subscriptionPeriod),
            "periodUnit": StoreProduct.rc_normalized(subscriptionPeriodUnit: subscriptionPeriod.unit),
            "periodNumberOfUnits": subscriptionPeriod.value,
            "cycles": numberOfPeriods
        ]
        
        if offerIdentifier != nil {
            dictionary["identifier"] = offerIdentifier
        }
        return dictionary
    }

}
