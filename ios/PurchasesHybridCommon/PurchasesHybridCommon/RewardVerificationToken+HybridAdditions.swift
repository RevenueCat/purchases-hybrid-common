//
//  RewardVerificationToken+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
@_spi(Experimental) import RevenueCat

internal extension RewardVerificationToken {

    var rc_dictionary: [String: Any] {
        return [
            "customData": self.customData,
            "clientTransactionId": self.clientTransactionID,
            "appUserID": self.appUserID,
        ]
    }

}
