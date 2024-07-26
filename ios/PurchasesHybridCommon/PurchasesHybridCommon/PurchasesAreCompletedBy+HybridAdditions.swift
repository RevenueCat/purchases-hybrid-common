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

    static func fromString(_ purchasesAreCompletedByString: String) -> PurchasesAreCompletedBy? {
        var purchasesAreCompletedBy: PurchasesAreCompletedBy? = nil
        if purchasesAreCompletedByString == "MY_APP" {
            purchasesAreCompletedBy = .myApp
        } else if purchasesAreCompletedByString == "REVENUECAT" {
            purchasesAreCompletedBy = .revenueCat
        } else {
            NSLog("Error: Unrecognized purchasesAreCompletedBy \(purchasesAreCompletedByString)")
        }
        return purchasesAreCompletedBy
    }

    var name: String {
        switch self {
        case .myApp: return "MY_APP"
        case .revenueCat: return "REVENUECAT"
        }
    }
}
