//
//  StoreProduct+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Josh Holtz on 3/7/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation

public extension StoreProduct {
    
    @objc var rc_currencyCode: String? {
        return self.currencyCode
    }
    
    @objc var rc_dictionary: [String: Any] {
        var dict: [String: Any] = [
            "identifier": self.productIdentifier,
            "description": self.localizedDescription,
            "title": self.localizedTitle,
            "price": self.price,
            "price_string": self.localizedPriceString,
            "currency_code": self.rc_currencyCode ?? NSNull()
        ]
        
        dict["intro_price"] = NSNull()
        dict["intro_price_string"] = NSNull()
        dict["intro_price_period"] = NSNull()
        dict["intro_price_period_unit"] = NSNull()
        dict["intro_price_period_number_of_units"] = NSNull()
        dict["intro_price_cycles"] = NSNull()
        dict["introPrice"] = NSNull()
        
        if #available(iOS 11.2, tvOS 11.2, macOS 10.13.2, *) {
            if let introductoryDiscount = self.introductoryDiscount {
                dict["intro_price"] = introductoryDiscount.price
                dict["intro_price_string"] = self.localizedIntroductoryPriceString
                dict["intro_price_period"] = StoreProduct.rc_normalizedSubscriptionPeriod(introductoryDiscount.subscriptionPeriod)
                dict["intro_price_period_unit"] = StoreProduct.rc_normalizedSubscriptionPeriod(introductoryDiscount.subscriptionPeriod)
                dict["intro_price_period_number_of_units"] = introductoryDiscount.subscriptionPeriod.value
                dict["intro_price_cycles"] = introductoryDiscount.subscriptionPeriod.value
                dict["introPrice"] = introductoryDiscount.rc_dictionary
            }
        }
        
        dict["discounts"] = NSNull()
    
        if #available(iOS 12.2, tvOS 12.2, macOS 10.14.4, *) {
            dict["discounts"] = self.discounts.map { $0.rc_dictionary }
        }
        
        return dict
    }
    
    @objc static func rc_normalizedSubscriptionPeriod(_ subscriptionPeriod: SubscriptionPeriod) -> String {
        let unit: String
        switch subscriptionPeriod.unit {
        case .day:
            unit = "D"
        case .week:
            unit = "W"
        case .month:
            unit = "M"
        case .year:
            unit = "Y"
        }
        return "P\(subscriptionPeriod.value)\(unit)"
    }
    
    @objc static func rc_normalizedSubscriptionPeriodUnit(_ subscriptionPeriod: SubscriptionPeriod) -> String {
        switch subscriptionPeriod.unit {
        case .day:
            return "DAY"
        case .week:
            return "WEEK"
        case .month:
            return "MONTH"
        case .year:
            return "YEAR"
        }
    }
    
}
