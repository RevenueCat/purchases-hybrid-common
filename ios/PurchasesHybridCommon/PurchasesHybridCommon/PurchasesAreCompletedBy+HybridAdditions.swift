//
//  PurchasesAreCompletedBy+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 7/26/24.
//  Copyright © 2024 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

public extension PurchasesAreCompletedBy {

    init?(name: String) {
        if let mode = Self.valuesByName[name] {
            self = mode
        } else {
            NSLog("Error: Unrecognized purchasesAreCompletedBy \(name)")
            return nil
        }
    }

    var name: String {
        switch self {
        case .myApp: return "MY_APP"
        case .revenueCat: return "REVENUECAT"
        }
    }

    private static let valuesByName: [String: Self] = [
        Self.myApp.name: Self.myApp,
        Self.revenueCat.name: Self.revenueCat,
    ]

}
