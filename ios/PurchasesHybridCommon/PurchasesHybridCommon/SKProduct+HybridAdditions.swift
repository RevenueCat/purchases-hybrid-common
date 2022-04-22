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

@objc public extension SKProduct {

    @objc var rc_dictionary: [String: Any] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale

        // Note: although identifier, description and title are supposed to be non-nil, we've seen instances
        // where this isn't true in practice (StoreKit bugs).
        // So we cast to optional and then check if it's actually nil.
        let nonNilProductIdentifier = productIdentifier as String? ?? ""
        let nonNilDescription = description as String? ?? ""
        let nonNilTitle = localizedTitle as String? ?? ""

        var dictionary: [String: Any] = [
            "identifier": nonNilProductIdentifier,
            "description": nonNilDescription,
            "title": nonNilTitle,
            "price": price.floatValue,
            "price_string": formatter.string(from: price) ?? "",
            "currency_code": priceLocale.currencyCode ?? NSNull(),
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
           let introductoryPrice = introductoryPrice {
            dictionary["intro_price"] = introductoryPrice.price.floatValue
            dictionary["intro_price_string"] = formatter.string(from: introductoryPrice.price)
            dictionary["intro_price_period"] = SKProduct.rc_normalized(subscriptionPeriod: introductoryPrice.subscriptionPeriod)
            dictionary["intro_price_period_unit"] = SKProduct.rc_normalized(subscriptionPeriodUnit: introductoryPrice.subscriptionPeriod.unit)
            dictionary["intro_price_period_number_of_units"] = introductoryPrice.subscriptionPeriod.numberOfUnits
            dictionary["intro_price_cycles"] = introductoryPrice.numberOfPeriods
            dictionary["introPrice"] = introductoryPrice.rc_dictionary
        }

        if #available(iOS 12.2, tvOS 12.2, macOS 10.14.4, *) {
            dictionary["discounts"] = discounts.map { $0.rc_dictionary }
        }

        return dictionary
    }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, *)
    @objc(rc_normalizedSubscriptionPeriod:)
    static func rc_normalized(subscriptionPeriod: SKProductSubscriptionPeriod) -> String {
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
        return "P\(subscriptionPeriod.numberOfUnits)\(unitString)"
    }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, *)
    @objc(rc_normalizedSubscriptionPeriodUnit:)
    static func rc_normalized(subscriptionPeriodUnit: SKProduct.PeriodUnit) -> String {
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
