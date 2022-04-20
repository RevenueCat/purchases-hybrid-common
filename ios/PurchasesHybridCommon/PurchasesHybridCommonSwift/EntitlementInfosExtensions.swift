//
//  EntitlementInfosExtensions.swift
//  PurchasesHybridCommonSwift
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import Purchases

@objc public extension Purchases.EntitlementInfos {

    var dictionary: [String: Any] {
        return [
            "all": all.mapValues { $0.dictionary },
            "active": active.mapValues { $0.dictionary }
        ]
    }

}

