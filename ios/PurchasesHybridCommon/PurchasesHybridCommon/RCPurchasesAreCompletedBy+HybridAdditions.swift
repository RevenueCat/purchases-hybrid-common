//
//  RCPurchasesAreCompletedBy+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 7/8/24.
//  Copyright © 2024 RevenueCat. All rights reserved.
//

import RevenueCat

public extension PurchasesAreCompletedBy {

    var name: String {
        switch self {
        case .revenueCat: return "REVENUECAT"
        case .myApp: return "MY_APP"
        }
    }

    init?(name: String) {
        if let completedBy = Self.completedByEntitiesByName[name] {
            self = completedBy
        } else {
            return nil
        }
    }

    private static let completedByEntitiesByName: [String: Self] = [
        Self.revenueCat.name: Self.revenueCat,
        Self.myApp.name: Self.myApp
    ]

}
