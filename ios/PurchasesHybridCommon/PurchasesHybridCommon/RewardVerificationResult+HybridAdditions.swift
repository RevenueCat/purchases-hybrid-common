//
//  RewardVerificationResult+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
@_spi(Experimental) import RevenueCat

internal extension RewardVerificationResult {

    var rc_dictionary: [String: Any] {
        guard let reward = self.verifiedReward else {
            return ["failed": true, "moreRewards": [[String: Any]]()]
        }
        return [
            "failed": false,
            "reward": reward.rc_dictionary,
            "moreRewards": self.moreRewards.map { $0.rc_dictionary },
        ]
    }

}
