//
//  VirtualCurrencies+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Will Taylor on 6/23/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import PurchasesHybridCommon
@_spi(Internal) @testable import RevenueCat

class VirtualCurrenciesHybridAdditionsTests: QuickSpec {
    override func spec() {
        describe("rc_dictionary") {
            it("has the right format when VCs are present") {
                let virtualCurrency1 = VirtualCurrency(
                    balance: 100,
                    name: "Coin",
                    code: "COIN",
                    serverDescription: "Hello world"
                )

                let virtualCurrency2 = VirtualCurrency(
                    balance: 100,
                    name: "Gem",
                    code: "GEM",
                    serverDescription: nil
                )

                let virtualCurrencies = VirtualCurrencies(virtualCurrencies: [
                    virtualCurrency1.code: virtualCurrency1,
                    virtualCurrency2.code: virtualCurrency2
                ])

                guard let receivedDictionary = virtualCurrencies.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(1))
                let all = try! XCTUnwrap(receivedDictionary["all"] as? [String: NSObject])
                expect(all.count).to(equal(2))

                let vc1 = try! XCTUnwrap(all[virtualCurrency1.code] as? [String: NSObject])
                expect(vc1["balance"] as? Int).to(equal(virtualCurrency1.balance))
                expect(vc1["name"] as? String).to(equal(virtualCurrency1.name))
                expect(vc1["code"] as? String).to(equal(virtualCurrency1.code))
                expect(vc1["serverDescription"] as? String?).to(equal(virtualCurrency1.serverDescription))

                let vc2 = try! XCTUnwrap(all[virtualCurrency2.code] as? [String: NSObject])
                expect(vc2["balance"] as? Int).to(equal(virtualCurrency2.balance))
                expect(vc2["name"] as? String).to(equal(virtualCurrency2.name))
                expect(vc2["code"] as? String).to(equal(virtualCurrency2.code))
                expect(vc2["serverDescription"] as? String?).to(beNil())
            }

            it("has the right format when there are no VCs") {
                let virtualCurrencies = VirtualCurrencies(virtualCurrencies: [:])

                guard let receivedDictionary = virtualCurrencies.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary.count).to(equal(1))
                let all = try! XCTUnwrap(receivedDictionary["all"] as? [String: NSObject])
                expect(all.isEmpty).to(beTrue())
            }
        }
    }
}
