//
//  VirtualCurrency+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Will Taylor on 3/27/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import PurchasesHybridCommon
@_spi(Internal) @testable import RevenueCat

class VirtualCurrencyHybridAdditionsTests: QuickSpec {
    override func spec() {
        describe("rc_dictionary") {
            it("has the right format when the description is present") {
                let expectedBalance: Int = 100
                let expectedName = "Coin"
                let expectedCode = "COIN"
                let expectedServerDescription = "Hello world"

                let virtualCurrency = VirtualCurrency(
                    balance: expectedBalance,
                    name: expectedName,
                    code: expectedCode,
                    serverDescription: expectedServerDescription
                )

                guard let receivedDictionary = virtualCurrency.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(4))
                expect(receivedDictionary["balance"] as? Int).to(equal(expectedBalance))
                expect(receivedDictionary["name"] as? String).to(equal(expectedName))
                expect(receivedDictionary["code"] as? String).to(equal(expectedCode))
                expect(receivedDictionary["serverDescription"] as? String?).to(equal(expectedServerDescription))
            }

            it("has the right format when the description is null") {
                let expectedBalance: Int = 100
                let expectedName = "Coin"
                let expectedCode = "COIN"
                let expectedServerDescription: String? = nil

                let virtualCurrency = VirtualCurrency(
                    balance: expectedBalance,
                    name: expectedName,
                    code: expectedCode,
                    serverDescription: expectedServerDescription
                )

                guard let receivedDictionary = virtualCurrency.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(4))
                expect(receivedDictionary["balance"] as? Int).to(equal(expectedBalance))
                expect(receivedDictionary["name"] as? String).to(equal(expectedName))
                expect(receivedDictionary["code"] as? String).to(equal(expectedCode))
                expect(receivedDictionary["serverDescription"] as? String?).to(beNil())
            }
        }
    }
}
