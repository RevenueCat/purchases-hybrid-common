//
//  VirtualCurrency+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 3/27/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

internal extension VirtualCurrency {

    var rc_dictionary: [String: Any] {
        return [
            "balance": self.balance,
            "name": self.name,
            "code": self.code,
            "serverDescription": self.serverDescription ?? NSNull(),
        ]
    }

}
