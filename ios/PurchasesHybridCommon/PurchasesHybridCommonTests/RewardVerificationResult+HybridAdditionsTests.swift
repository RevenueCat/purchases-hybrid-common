//
//  RewardVerificationResult+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
import Quick
import Nimble

@_spi(Experimental) @testable import PurchasesHybridCommon
@_spi(Internal) @_spi(Experimental) @testable import RevenueCat

class RewardVerificationResultHybridAdditionsTests: QuickSpec {
    override func spec() {
        describe("rc_dictionary") {
            it("has the right format when verification failed") {
                let result = RewardVerificationResult.failed

                guard let receivedDictionary = result.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(2))
                expect(receivedDictionary["failed"] as? Bool).to(equal(true))
                expect(receivedDictionary["moreRewards"] as? [[String: NSObject]]).to(equal([]))
            }

            it("has the right format when verification succeeded") {
                let payload = VirtualCurrencyReward(code: "GLD", amount: 100)!
                let reward = AdReward.virtualCurrency(payload)
                let moreReward = AdReward.noReward
                let result = RewardVerificationResult.verified(reward, moreRewards: [moreReward])

                guard let receivedDictionary = result.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(3))
                expect(receivedDictionary["failed"] as? Bool).to(equal(false))
                expect(receivedDictionary["reward"] as? [String: NSObject]).to(equal(reward.rc_dictionary as? [String: NSObject]))
                expect(receivedDictionary["moreRewards"] as? [[String: NSObject]])
                    .to(equal([moreReward.rc_dictionary as! [String: NSObject]]))
            }
        }
    }
}
