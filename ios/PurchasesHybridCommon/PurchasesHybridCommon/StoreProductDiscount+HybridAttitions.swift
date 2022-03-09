//
//  StoreProductDiscount+HybridAttitions.swift
//  PurchasesHybridCommon
//
//  Created by Josh Holtz on 3/7/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation

public extension StoreProductDiscount {

    @objc var rc_dictionary: [String: Any] {
        var dict: [String: Any] = [
            "price": self.price,
            "priceString": self.localizedPriceString,
            "periodNumberOfUnits": self.subscriptionPeriod.value,
            "cycles": self.subscriptionPeriod.value
        ]
        
        if #available(iOS 11.2, *) {
            dict["period"] = StoreProduct.rc_normalizedSubscriptionPeriod(self.subscriptionPeriod)
            dict["periodUnit"] = StoreProduct.rc_normalizedSubscriptionPeriodUnit(self.subscriptionPeriod)
        }
        
        if let offerIdentifier = self.offerIdentifier {
            dict["identifier"] = offerIdentifier
        }
        
        return dict
    }
    
}
