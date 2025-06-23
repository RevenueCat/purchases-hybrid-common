//
//  VirtualCurrencies+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 6/23/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

internal extension VirtualCurrencies {

    var rc_dictionary: [String: Any] {
        return [
            "all": all.mapValues { $0.rc_dictionary },
        ]
    }
}
