//
//  OfferingExtensions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import Purchases

@objc public extension Purchases.Offering {

    @objc var dictionary: [String: Any] {
        var result: [String: Any] = [
            "identifier": identifier,
            "serverDescription": serverDescription,
            "availablePackages": availablePackages.map { $0.dictionary(identifier) }
        ]

        if let lifetime = lifetime {
            result["lifetime"] = lifetime.dictionary(identifier)
        }
        if let annual = annual {
            result["lifetime"] = annual.dictionary(identifier)
        }
        if let sixMonth = sixMonth {
            result["lifetime"] = sixMonth.dictionary(identifier)
        }
        if let threeMonth = threeMonth {
            result["lifetime"] = threeMonth.dictionary(identifier)
        }
        if let twoMonth = twoMonth {
            result["lifetime"] = twoMonth.dictionary(identifier)
        }
        if let monthly = monthly {
            result["lifetime"] = monthly.dictionary(identifier)
        }
        if let weekly = weekly {
            result["lifetime"] = weekly.dictionary(identifier)
        }

        return result
    }

}
