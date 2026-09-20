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
            "identifier": self.rc_compoundProductIdentifier,
            "installmentsInfo": NSNull(),
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
            "productPlanIdentifier": self.rc_productPlanIdentifier ?? NSNull(),
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

        if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *),
           let installmentsInfo = self.installmentsInfo {
            dictionary["installmentsInfo"] = installmentsInfo.rc_dictionary
        }
        
        return dictionary
    }

    /// The plan component of this product's identifier, when the product represents a specific billing plan of a
    /// StoreKit product (Apple's monthly billing with a commitment): `"monthly"`. `nil` for a plain product.
    ///
    /// Mirrors `BillingPlanType.compoundProductIDPlanComponent` in purchases-ios, which is internal to that module:
    /// an `upFront` plan is the StoreKit product itself and has no plan component.
    var rc_productPlanIdentifier: String? {
        guard #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *),
              let billingPlanType = self.installmentsInfo?.billingPlanType,
              billingPlanType != .upFront else {
            return nil
        }

        return billingPlanType.rawValue
    }

    /// The identifier purchases-ios resolves this product by: `{productIdentifier}` for a plain product and
    /// `{productIdentifier}:{productPlanIdentifier}` for a billing plan product (e.g. `annual:monthly`).
    ///
    /// This is the identifier the hybrid SDKs expose as `identifier` and accept back when purchasing by product,
    /// so an app can tell a billing plan product apart from the upfront product backed by the same StoreKit product.
    /// It matches the `identifier` Android emits (`StoreProduct.id`, `{productId}:{basePlanId}` for subscriptions).
    var rc_compoundProductIdentifier: String {
        guard let productPlanIdentifier = self.rc_productPlanIdentifier else {
            return self.productIdentifier
        }

        return "\(self.productIdentifier):\(productPlanIdentifier)"
    }

    /// Maps a period to the shape the hybrid `Period` type uses (`unit`, `value`, `iso8601`), as Android does.
    static func rc_periodDictionary(_ period: RevenueCat.SubscriptionPeriod) -> [String: Any] {
        return [
            "unit": Self.rc_normalized(subscriptionPeriodUnit: period.unit),
            "value": period.value,
            "iso8601": Self.rc_normalized(subscriptionPeriod: period)
        ]
    }

    static func rc_normalized(subscriptionPeriod: RevenueCat.SubscriptionPeriod) -> String {
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

    static func rc_normalized(subscriptionPeriodUnit: RevenueCat.SubscriptionPeriod.Unit) -> String {
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

internal extension InstallmentsInfo {

    var rc_dictionary: [String: Any] {
        return [
            "commitmentInstallmentsCount": self.commitmentInstallmentsCount,
            "commitmentInstallmentPeriod": StoreProduct.rc_periodDictionary(self.commitmentInstallmentPeriod),
            "installmentBillingPrice": self.installmentBillingPrice,
            "installmentBillingDisplayPrice": self.installmentBillingDisplayPrice,
            "commitmentTotalPeriod": StoreProduct.rc_periodDictionary(self.commitmentTotalPeriod),
            "commitmentTotalPrice": self.commitmentTotalPrice,
            "commitmentTotalDisplayPrice": self.commitmentTotalDisplayPrice,
            "billingPlanType": self.billingPlanType.rc_name
        ]
    }

}

internal extension BillingPlanType {

    var rc_name: String {
        switch self {
        case .upFront:
            return "UP_FRONT"
        case .monthly:
            return "MONTHLY"
        default:
            return self.rawValue.uppercased()
        }
    }

}
