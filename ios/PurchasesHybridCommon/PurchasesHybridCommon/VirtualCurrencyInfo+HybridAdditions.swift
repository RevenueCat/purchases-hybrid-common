//
//  VirtualCurrencyInfo+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 3/27/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

internal extension VirtualCurrencyInfo {

    var rc_dictionary: [String: Any] {
        return [
            "balance": self.balance
        ]
    }

}
