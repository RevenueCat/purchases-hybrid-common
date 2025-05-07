//
//  Offering+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Josh Holtz on 5/31/23.
//  Copyright © 2023 RevenueCat. All rights reserved.
//

import Quick
import Nimble
@testable import PurchasesHybridCommon
@testable import RevenueCat
import Foundation

class OfferingInfoHybridAdditionsTests: QuickSpec {

    override func spec() {
        describe("rc_dictionary") {
            context("metadata") {
                it("contains the empty metadata") {
                    let mockOffering = Offering(
                        identifier: "default",
                        serverDescription: "The default offering",
                        metadata: [:],
                        availablePackages: [
                            .init(
                                identifier: "annual",
                                packageType: .annual,
                                storeProduct: TestStoreProduct().toStoreProduct(),
                                offeringIdentifier: "default",
                                webCheckoutUrl: nil
                            )
                        ],
                        webCheckoutUrl: nil
                    )

                    let dictionary = mockOffering.dictionary
                    expect(dictionary["metadata"] as? [String: Any]).to(haveCount(0))
                }

                it("contains the metadata of all types") {
                    let mockOffering = Offering(
                        identifier: "default",
                        serverDescription: "The default offering",
                        metadata: [
                            "int": 5,
                            "double": 5.5,
                            "boolean": true,
                            "string": "five",
                            "array": ["five"],
                            "dictionary": [
                                "string": "five"
                            ]
                        ],
                        availablePackages: [
                            .init(
                                identifier: "annual",
                                packageType: .annual,
                                storeProduct: TestStoreProduct().toStoreProduct(),
                                offeringIdentifier: "default",
                                webCheckoutUrl: nil
                            )
                        ],
                        webCheckoutUrl: nil
                    )

                    let dictionary = mockOffering.dictionary
                    expect(dictionary["metadata"] as? [String: Any]).to(haveCount(6))
                }
            }
        }
    }
}

// These are `enum`s, but for some reason Swift doesn't make them implicitly Sendable.
extension StoreProduct.ProductCategory: @unchecked Sendable {}
extension StoreProduct.ProductType: @unchecked Sendable {}

private extension TestStoreProduct {

    init() {
        self.init(
            localizedTitle: "",
            price: 0.0,
            localizedPriceString: "",
            productIdentifier: "",
            productType: .autoRenewableSubscription,
            localizedDescription: ""
        )
    }

}
