//
//  SKProduct+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import StoreKit
import RevenueCat

@objc public extension StoreProduct {

    @objc var rc_dictionary: [String: Any] {
        var dictionary: [String: Any] = [
            "identifier": productIdentifier,
            "description": localizedDescription,
            "title": localizedTitle,
            "price": price,
            "price_string": localizedPriceString,
            "currency_code": currencyCode ?? NSNull(),
            "intro_price": NSNull(),
            "intro_price_string": NSNull(),
            "intro_price_period": NSNull(),
            "intro_price_period_unit": NSNull(),
            "intro_price_period_number_of_units": NSNull(),
            "intro_price_cycles": NSNull(),
            "introPrice": NSNull(),
            "discounts": NSNull(),
        ]

        if #available(iOS 11.2, tvOS 11.2, macOS 10.13.2, *),
           let introductoryDiscount = introductoryDiscount {
            dictionary["intro_price"] = introductoryDiscount.price
            dictionary["intro_price_string"] = introductoryDiscount.localizedPriceString
            dictionary["intro_price_period"] = StoreProduct.rc_normalized(subscriptionPeriod: introductoryDiscount.subscriptionPeriod)
            dictionary["intro_price_period_unit"] = StoreProduct.rc_normalized(subscriptionPeriodUnit: introductoryDiscount.subscriptionPeriod.unit)
            dictionary["intro_price_period_number_of_units"] = introductoryDiscount.subscriptionPeriod.value
            dictionary["intro_price_cycles"] = introductoryDiscount.numberOfPeriods
            dictionary["introPrice"] = introductoryDiscount.rc_dictionary
        }

        if #available(iOS 12.2, tvOS 12.2, macOS 10.14.4, *) {
            dictionary["discounts"] = discounts.map { $0.rc_dictionary }
        }

        return dictionary
    }

    @objc(rc_normalizedSubscriptionPeriod:)
    static func rc_normalized(subscriptionPeriod: SubscriptionPeriod) -> String {
        let unitString: String
        switch subscriptionPeriod.unit {
        case .day:
            unitString = "D"
        case .week:
            unitString = "W"
        case .month:
            unitString = "M"
        case .year:
            unitString = "Y"
        @unknown default:
            unitString = "-"
        }
        return "P\(subscriptionPeriod.value)\(unitString)"
    }

    @objc(rc_normalizedSubscriptionPeriodUnit:)
    static func rc_normalized(subscriptionPeriodUnit: SubscriptionPeriod.Unit) -> String {
        switch subscriptionPeriodUnit {
        case .day:
            return "DAY"
        case .week:
            return "WEEK"
        case .month:
            return "MONTH"
        case .year:
            return "YEAR"
        @unknown default:
            return "-"
        }
    }

}
