//
//  EntitlementInfo+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Will Taylor on 5/24/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Quick
import Nimble
@testable import PurchasesHybridCommon
@testable import RevenueCat

class EntitlementInfoHybridAdditionsTests: QuickSpec {

    private static let expiresDate = "9999-01-01T00:00:00Z"
    private static let purchaseDate = "1999-07-26T23:30:41Z"
    private let mockEntitlementData = [
        "expires_date": EntitlementInfoHybridAdditionsTests.expiresDate,
        "product_identifier": "pro",
        "purchase_date": EntitlementInfoHybridAdditionsTests.purchaseDate
    ]

    override func spec() {
        describe("rc_dictionary") {
            context("store") {
                it("equals APP_STORE when the store is app store") {
                    let expectedDictionaryValue = "APP_STORE"
                    guard let mockEntitlementInfo = EntitlementInfo(
                        entitlementId: "pro",
                        entitlementData: self.mockEntitlementData,
                        productData: self.mockProductData(withStore: "app_store"),
                        requestDate: nil
                    ) else {
                        fail("Could not create mock EntitlementInfo object.")
                        return
                    }

                    let dictionary = mockEntitlementInfo.dictionary
                    expect(dictionary["store"] as? String).to(
                        equal(expectedDictionaryValue),
                        description: "Expected \(String(describing: dictionary["store"] as? String)) to become \(expectedDictionaryValue)."
                    )
                }
                it("equals MAC APP STORE when the store is mac app store") {
                    let expectedDictionaryValue = "MAC_APP_STORE"
                    guard let mockEntitlementInfo = EntitlementInfo(
                        entitlementId: "pro",
                        entitlementData: self.mockEntitlementData,
                        productData: self.mockProductData(withStore: "mac_app_store"),
                        requestDate: nil
                    ) else {
                        fail("Could not create mock EntitlementInfo object.")
                        return
                    }

                    let dictionary = mockEntitlementInfo.dictionary
                    expect(dictionary["store"] as? String).to(
                        equal(expectedDictionaryValue),
                        description: "Expected \(String(describing: dictionary["store"] as? String)) to become \(expectedDictionaryValue)."
                    )
                }
                it("equals PLAY STORE when the store is play store") {
                    let expectedDictionaryValue = "PLAY_STORE"
                    guard let mockEntitlementInfo = EntitlementInfo(
                        entitlementId: "pro",
                        entitlementData: self.mockEntitlementData,
                        productData: self.mockProductData(withStore: "play_store"),
                        requestDate: nil
                    ) else {
                        fail("Could not create mock EntitlementInfo object.")
                        return
                    }

                    let dictionary = mockEntitlementInfo.dictionary
                    expect(dictionary["store"] as? String).to(
                        equal(expectedDictionaryValue),
                        description: "Expected \(String(describing: dictionary["store"] as? String)) to become \(expectedDictionaryValue)."
                    )
                }
                it("equals STRIPE when the store is Stripe") {
                    let expectedDictionaryValue = "STRIPE"
                    guard let mockEntitlementInfo = EntitlementInfo(
                        entitlementId: "pro",
                        entitlementData: self.mockEntitlementData,
                        productData: self.mockProductData(withStore: "stripe"),
                        requestDate: nil
                    ) else {
                        fail("Could not create mock EntitlementInfo object.")
                        return
                    }

                    let dictionary = mockEntitlementInfo.dictionary
                    expect(dictionary["store"] as? String).to(
                        equal(expectedDictionaryValue),
                        description: "Expected \(String(describing: dictionary["store"] as? String)) to become \(expectedDictionaryValue)."
                    )
                }
                it("equals PROMOTIONAL when the store is promotional") {
                    let expectedDictionaryValue = "PROMOTIONAL"
                    guard let mockEntitlementInfo = EntitlementInfo(
                        entitlementId: "pro",
                        entitlementData: self.mockEntitlementData,
                        productData: self.mockProductData(withStore: "promotional"),
                        requestDate: nil
                    ) else {
                        fail("Could not create mock EntitlementInfo object.")
                        return
                    }

                    let dictionary = mockEntitlementInfo.dictionary
                    expect(dictionary["store"] as? String).to(
                        equal(expectedDictionaryValue),
                        description: "Expected \(String(describing: dictionary["store"] as? String)) to become \(expectedDictionaryValue)."
                    )
                }
                it("equals AMAZON when the store is amazon") {
                    let expectedDictionaryValue = "AMAZON"
                    guard let mockEntitlementInfo = EntitlementInfo(
                        entitlementId: "pro",
                        entitlementData: self.mockEntitlementData,
                        productData: self.mockProductData(withStore: "amazon"),
                        requestDate: nil
                    ) else {
                        fail("Could not create mock EntitlementInfo object.")
                        return
                    }

                    let dictionary = mockEntitlementInfo.dictionary
                    expect(dictionary["store"] as? String).to(
                        equal(expectedDictionaryValue),
                        description: "Expected \(String(describing: dictionary["store"] as? String)) to become \(expectedDictionaryValue)."
                    )
                }
                it("equals UNKNOWN when the store is unknown") {
                    let expectedDictionaryValue = "UNKNOWN_STORE"
                    guard let mockEntitlementInfo = EntitlementInfo(
                        entitlementId: "pro",
                        entitlementData: self.mockEntitlementData,
                        productData: self.mockProductData(withStore: "unknown"),
                        requestDate: nil
                    ) else {
                        fail("Could not create mock EntitlementInfo object.")
                        return
                    }

                    let dictionary = mockEntitlementInfo.dictionary
                    expect(dictionary["store"] as? String).to(
                        equal(expectedDictionaryValue),
                        description: "Expected \(String(describing: dictionary["store"] as? String)) to become \(expectedDictionaryValue)."
                    )
                }
            }
        }
    }

    private func mockProductData(withStore store: String) -> [String: Any] {
        return [
            "expires_date": Self.expiresDate,
            "original_purchase_date": Self.purchaseDate,
            "period_type": "normal",
            "purchase_date": Self.purchaseDate,
            "store": store
        ]
    }
}
