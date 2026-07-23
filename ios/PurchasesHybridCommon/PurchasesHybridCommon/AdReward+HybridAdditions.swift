//
//  AdReward+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
@_spi(Experimental) import RevenueCat

internal extension AdReward {

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
                "expiresAt": entitlement.expiresAt.rc_formattedAsISO8601(),
                "expiresAtMillis": entitlement.expiresAt.rc_millisecondsSince1970AsDouble(),
            ]
        }
        return ["type": self == .noReward ? "no_reward" : "unsupported_reward"]
    }

}
