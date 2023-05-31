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
                                storeProduct: MockStoreProduct(),
                                offeringIdentifier: "default"
                            )
                        ]
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
                                storeProduct: MockStoreProduct(),
                                offeringIdentifier: "default"
                            )
                        ]
                    )

                    let dictionary = mockOffering.dictionary
                    expect(dictionary["metadata"] as? [String: Any]).to(haveCount(6))
                }
            }
        }
    }
}

private final class MockStoreProduct: StoreProductType, Sendable {

    var productCategory: RevenueCat.StoreProduct.ProductCategory = .subscription

    var productType: RevenueCat.StoreProduct.ProductType = .autoRenewableSubscription

    var localizedDescription: String = ""

    var localizedTitle: String = ""

    var currencyCode: String? = ""

    var price: Decimal = 0.0

    var localizedPriceString: String = ""

    var productIdentifier: String = ""

    var isFamilyShareable: Bool = false

    var subscriptionGroupIdentifier: String? = nil

    var priceFormatter: NumberFormatter? = nil

    var subscriptionPeriod: RevenueCat.SubscriptionPeriod? = nil

    var introductoryDiscount: RevenueCat.StoreProductDiscount? = nil

    var discounts: [RevenueCat.StoreProductDiscount] = []

}
