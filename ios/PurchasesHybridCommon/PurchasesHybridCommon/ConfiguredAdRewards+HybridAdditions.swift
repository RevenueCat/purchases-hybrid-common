//
//  ConfiguredAdRewards+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

internal extension ConfiguredAdRewards {

    var rc_dictionary: [String: Any] {
        return [
            "reward": self.reward.map { $0.rc_dictionary as Any } ?? NSNull(),
            "moreRewards": self.moreRewards.map { $0.rc_dictionary },
        ]
    }

}

internal extension AdRewardConfiguration {

    var rc_dictionary: [String: Any] {
        if let virtualCurrency = self.virtualCurrency {
            return [
                "type": "virtual_currency",
                "code": virtualCurrency.code,
                "amount": virtualCurrency.amount,
            ]
        }
        if let entitlement = self.entitlement {
            return [
                "type": "entitlement",
                "identifier": entitlement.identifier,
                "durationSeconds": entitlement.duration,
            ]
        }
        return ["type": "unsupported_reward"]
    }

}
