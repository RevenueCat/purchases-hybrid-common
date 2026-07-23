//
//  AdReward+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import PurchasesHybridCommon
@_spi(Internal) @_spi(Experimental) @testable import RevenueCat

class AdRewardHybridAdditionsTests: QuickSpec {
    override func spec() {
        describe("rc_dictionary") {
            it("has the right format for a virtual currency reward") {
                let payload = VirtualCurrencyReward(code: "GLD", amount: 100)!
                let reward = AdReward.virtualCurrency(payload)

                guard let receivedDictionary = reward.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(3))
                expect(receivedDictionary["type"] as? String).to(equal("virtual_currency"))
                expect(receivedDictionary["code"] as? String).to(equal("GLD"))
                expect(receivedDictionary["amount"] as? Int).to(equal(100))
            }

            it("has the right format for an entitlement reward") {
                let expiresAt = Date()
                let payload = EntitlementReward(identifier: "premium", expiresAt: expiresAt)!
                let reward = AdReward.entitlement(payload)

                guard let receivedDictionary = reward.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(4))
                expect(receivedDictionary["type"] as? String).to(equal("entitlement"))
                expect(receivedDictionary["identifier"] as? String).to(equal("premium"))
                expect(receivedDictionary["expiresAt"] as? String).to(equal(expiresAt.rc_formattedAsISO8601()))
                expect(receivedDictionary["expiresAtMillis"] as? Double)
                    .to(equal(expiresAt.rc_millisecondsSince1970AsDouble()))
            }

            it("has the right format for no reward") {
                let reward = AdReward.noReward

                guard let receivedDictionary = reward.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(1))
                expect(receivedDictionary["type"] as? String).to(equal("no_reward"))
            }

            it("has the right format for an unsupported reward") {
                let reward = AdReward.unsupportedReward

                guard let receivedDictionary = reward.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(1))
                expect(receivedDictionary["type"] as? String).to(equal("unsupported_reward"))
            }
        }
    }
}
