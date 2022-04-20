//
//  SKProductDiscountExtensions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import StoreKit

@available(iOS 11.2, macOS 10.13.2, tvOS 11.2, *)
@objc public extension SKProductDiscount {

    @objc var rc_currencyCode: String? {
        return priceLocale.currencyCode
    }

    @objc var rc_dictionary: [String: Any] {

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale

        var dictionary: [String: Any] = [
            "price": price.floatValue,
            "priceString": formatter.string(from: price) ?? "",
            "period": SKProduct.rc_normalized(subscriptionPeriod: subscriptionPeriod),
            "periodUnit": SKProduct.rc_normalized(subscriptionPeriodUnit: subscriptionPeriod.unit),
            "periodNumberOfUnits": subscriptionPeriod.numberOfUnits,
            "cycles": numberOfPeriods
        ]
        
        if #available(iOS 12.2, tvOS 12.2, macOS 10.14.4, *) {
            if identifier != nil {
                dictionary["identifier"] = identifier
            }
        }
        return dictionary
    }

}
