//
//  RewardVerificationToken+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import PurchasesHybridCommon
@_spi(Internal) @_spi(Experimental) @testable import RevenueCat

class RewardVerificationTokenHybridAdditionsTests: QuickSpec {
    override func spec() {
        describe("rc_dictionary") {
            it("has the right format") {
                let token = RewardVerificationToken(
                    customData: "custom-data",
                    clientTransactionID: "client-transaction-id",
                    appUserID: "app-user-id"
                )

                guard let receivedDictionary = token.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(3))
                expect(receivedDictionary["customData"] as? String).to(equal("custom-data"))
                expect(receivedDictionary["clientTransactionId"] as? String).to(equal("client-transaction-id"))
                expect(receivedDictionary["appUserID"] as? String).to(equal("app-user-id"))
            }
        }
    }
}
