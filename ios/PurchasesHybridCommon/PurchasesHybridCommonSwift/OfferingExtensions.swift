//
//  OfferingExtensions.swift
//  PurchasesHybridCommonSwift
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import Purchases

@objc public extension Purchases.Offering {

    @objc var dictionary: [String: Any] {
        return [
            "identifier": identifier,
            "serverDescription": serverDescription,
            "availablePackages": availablePackages.map { $0.dictionary(identifier) },
            "lifetime": lifetime?.dictionary(identifier) ?? "<null>",
            "annual": annual?.dictionary(identifier) ?? "<null>",
            "sixMonth": sixMonth?.dictionary(identifier) ?? "<null>",
            "threeMonth": threeMonth?.dictionary(identifier) ?? "<null>",
            "twoMonth":twoMonth?.dictionary(identifier) ?? "<null>",
            "monthly":monthly?.dictionary(identifier) ?? "<null>",
            "weekly":weekly?.dictionary(identifier) ?? "<null>"
        ]
    }

}
