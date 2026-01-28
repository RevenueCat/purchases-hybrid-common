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
                it("is properly set") {
                    let expectations: [(Store, String)] = [
                        (.appStore, "APP_STORE"),
                        (.macAppStore, "MAC_APP_STORE"),
                        (.playStore, "PLAY_STORE"),
                        (.stripe, "STRIPE"),
                        (.promotional, "PROMOTIONAL"),
                        (.amazon, "AMAZON"),
                        (.rcBilling, "RC_BILLING"),
                        (.external, "EXTERNAL"),
                        (.paddle, "PADDLE"),
                        (.testStore, "TEST_STORE"),
                        (.galaxy, "GALAXY"),
                        (.unknownStore, "UNKNOWN_STORE")
                    ]

                    for expectation in expectations {
                        let (store, expectedDictionaryValue) = expectation
                        let mockEntitlementInfo = self.mockEntitlementInfo(store: store)

                        let dictionary = mockEntitlementInfo.dictionary
                        expect(dictionary["store"] as? String).to(
                            equal(expectedDictionaryValue),
                            description: "Expected \(store) to be encoded as \(expectedDictionaryValue)."
                        )
                    }
                }
            }

            context("verification") {
                it("is properly set") {
                    let mockEntitlementInfo = self.mockEntitlementInfo(store: Store.appStore)
                    let dictionary = mockEntitlementInfo.dictionary

                    expect(dictionary["verification"] as? String).to(equal("NOT_REQUESTED"))
                }
            }
        }
    }

    private func mockEntitlementInfo(store: Store) -> EntitlementInfo {
        return EntitlementInfo(
            identifier: "",
            entitlement: .init(productIdentifier: "productId", rawData: self.mockEntitlementData),
            subscription: .init(
                periodType: .normal,
                purchaseDate: Date(),
                originalPurchaseDate: nil,
                expiresDate: nil,
                store: store,
                isSandbox: false,
                unsubscribeDetectedAt: nil,
                billingIssuesDetectedAt: nil,
                ownershipType: .purchased
            ),
            sandboxEnvironmentDetector: MockSandboxEnvironmentDetector(),
            verification: .notRequested,
            requestDate: .init()
        )
    }
}
