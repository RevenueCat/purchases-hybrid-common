//
//  SKProduct+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat
import StoreKit

@objc public extension StoreProduct {
    
    // Re-exports price properties with different names to avoid recursion.

    @objc var priceAmount: NSDecimalNumber {
        return self.priceDecimalNumber
    }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    @objc var pricePerWeekAmount: NSDecimalNumber? {
        return self.pricePerWeek
    }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    @objc var pricePerMonthAmount: NSDecimalNumber? {
        return self.pricePerMonth
    }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    @objc var pricePerYearAmount: NSDecimalNumber? {
        return self.pricePerYear
    }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    @objc var pricePerWeekString: String? {
        return self.localizedPricePerWeek
    }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    @objc var pricePerMonthString: String? {
        return self.localizedPricePerMonth
    }

    @available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *)
    @objc var pricePerYearString: String? {
        return self.localizedPricePerYear
    }

}

internal extension StoreProduct {

    var rc_dictionary: [String: Any] {
        var dictionary: [String: Any] = [
            "currencyCode": self.currencyCode ?? NSNull(),
            "description": self.localizedDescription,
            "discounts": NSNull(),
            "identifier": self.productIdentifier,
            "introPrice": NSNull(),
            "price": self.price,
            "priceString": self.localizedPriceString,
            "pricePerWeek": NSNull(),
            "pricePerMonth": NSNull(),
            "pricePerYear": NSNull(),
            "pricePerWeekString": NSNull(),
            "pricePerMonthString": NSNull(),
            "pricePerYearString": NSNull(),
            "productCategory": self.productCategoryString,
            "productType": self.productTypeString,
            "title": self.localizedTitle,
            "subscriptionPeriod": NSNull(),
        ]

        dictionary["pricePerWeek"] = self.pricePerWeek
        dictionary["pricePerMonth"] = self.pricePerMonth
        dictionary["pricePerYear"] = self.pricePerYear
        dictionary["pricePerWeekString"] = self.localizedPricePerWeek
        dictionary["pricePerMonthString"] = self.localizedPricePerMonth
        dictionary["pricePerYearString"] = self.localizedPricePerYear

        if let introductoryDiscount = self.introductoryDiscount {
            dictionary["introPrice"] = introductoryDiscount.rc_dictionary
        }

        dictionary["discounts"] = self.discounts.map { $0.rc_dictionary }

        if let subscriptionPeriod = self.subscriptionPeriod {
            dictionary["subscriptionPeriod"] = StoreProduct.rc_normalized(subscriptionPeriod: subscriptionPeriod)
        }
        
        return dictionary
    }

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

private extension StoreProduct {

    var productCategoryString: String {
        switch self.productCategory {
        case .nonSubscription:
            return "NON_SUBSCRIPTION"
        case .subscription:
            return "SUBSCRIPTION"
        }
    }

    var productTypeString: String {
        switch self.productType {
        case .consumable:
            return "CONSUMABLE"
        case .nonConsumable:
            return "NON_CONSUMABLE"
        case .nonRenewableSubscription:
            return "NON_RENEWABLE_SUBSCRIPTION"
        case .autoRenewableSubscription:
            return "AUTO_RENEWABLE_SUBSCRIPTION"
        }
    }

}
