//
//  CommonPurchaseParamsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Antonio Rico Diez on 30/9/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Quick
import Foundation
import Nimble
@testable import PurchasesHybridCommon
@testable import RevenueCat

class CommonPurchaseParamsTests: QuickSpec {

    override func spec() {
        describe("validatePurchaseParams") {
            context("with packageIdentifier") {
                it("creates CommonPurchaseParams with package") {
                    let options: [String: Any] = ["packageIdentifier": "test_package"]

                    let result = try? CommonFunctionality.validatePurchaseParams(options)

                    expect(result).toNot(beNil())
                    if case .package(let identifier) = result?.purchasableItem {
                        expect(identifier) == "test_package"
                    } else {
                        fail("Expected package purchasable item")
                    }
                    expect(result?.signedDiscountTimestamp).to(beNil())
                    expect(result?.winBackOfferID).to(beNil())
                    expect(result?.presentedOfferingContext).to(beNil())
                }

                it("includes optional parameters") {
                    let presentedOfferingContext = ["offering_id": "test_offering"]
                    let options: [String: Any] = [
                        "packageIdentifier": "test_package",
                        "signedDiscountTimestamp": "123456",
                        "winBackOfferID": "winback_123",
                        "presentedOfferingContext": presentedOfferingContext
                    ]

                    let result = try? CommonFunctionality.validatePurchaseParams(options)

                    expect(result).toNot(beNil())
                    expect(result?.signedDiscountTimestamp) == "123456"
                    expect(result?.winBackOfferID) == "winback_123"
                    expect(result?.presentedOfferingContext?["offering_id"] as? String) == "test_offering"
                }
            }

            context("with productIdentifier") {
                it("creates CommonPurchaseParams with product") {
                    let options: [String: Any] = ["productIdentifier": "test_product"]

                    let result = try? CommonFunctionality.validatePurchaseParams(options)

                    expect(result).toNot(beNil())
                    if case .product(let identifier) = result?.purchasableItem {
                        expect(identifier) == "test_product"
                    } else {
                        fail("Expected product purchasable item")
                    }
                    expect(result?.signedDiscountTimestamp).to(beNil())
                    expect(result?.winBackOfferID).to(beNil())
                    expect(result?.presentedOfferingContext).to(beNil())
                }

                it("includes optional parameters") {
                    let presentedOfferingContext = ["offering_id": "test_offering"]
                    let options: [String: Any] = [
                        "productIdentifier": "test_product",
                        "signedDiscountTimestamp": "789012",
                        "winBackOfferID": "winback_456",
                        "presentedOfferingContext": presentedOfferingContext
                    ]

                    let result = try? CommonFunctionality.validatePurchaseParams(options)

                    expect(result).toNot(beNil())
                    expect(result?.signedDiscountTimestamp) == "789012"
                    expect(result?.winBackOfferID) == "winback_456"
                    expect(result?.presentedOfferingContext?["offering_id"] as? String) == "test_offering"
                }
            }

            context("introductory offer eligibility JWS") {
                it("preserves a signed token unchanged for both purchase paths") {
                    for identifier in ["productIdentifier", "packageIdentifier"] {
                        let result = try CommonFunctionality.validatePurchaseParams([
                            identifier: "test_item",
                            "introductoryOfferEligibilityJWS": "header.deny-intro.signature"
                        ])
                        expect(result.introductoryOfferEligibilityJWS) == "header.deny-intro.signature"
                    }
                }

                it("treats omitted and null tokens as absent") {
                    for options: [String: Any] in [
                        ["productIdentifier": "test_product"],
                        ["productIdentifier": "test_product", "introductoryOfferEligibilityJWS": NSNull()]
                    ] {
                        let result = try CommonFunctionality.validatePurchaseParams(options)
                        expect(result.introductoryOfferEligibilityJWS).to(beNil())
                    }
                }

                it("rejects empty and incorrectly typed tokens instead of discarding them") {
                    for value: Any in ["", false, 123, ["token"]] {
                        expect {
                            try CommonFunctionality.validatePurchaseParams([
                                "productIdentifier": "test_product",
                                "introductoryOfferEligibilityJWS": value
                            ])
                        }.to(throwError { error in
                            expect((error as NSError).code) == ErrorCode.purchaseInvalidError.rawValue
                        })
                    }
                }

                it("rejects offer combinations rather than losing the eligibility token") {
                    for offer in ["signedDiscountTimestamp", "winBackOfferID"] {
                        expect {
                            try CommonFunctionality.validatePurchaseParams([
                                "productIdentifier": "test_product",
                                "introductoryOfferEligibilityJWS": "header.deny-intro.signature",
                                offer: "offer"
                            ])
                        }.to(throwError())
                    }
                }
            }

            context("priority") {
                it("prefers packageIdentifier over productIdentifier when both are present") {
                    let options: [String: Any] = [
                        "packageIdentifier": "test_package",
                        "productIdentifier": "test_product"
                    ]

                    let result = try? CommonFunctionality.validatePurchaseParams(options)

                    expect(result).toNot(beNil())
                    if case .package(let identifier) = result?.purchasableItem {
                        expect(identifier) == "test_package"
                    } else {
                        fail("Expected package purchasable item when both are present")
                    }
                }
            }

            context("error handling") {
                it("throws error when neither packageIdentifier nor productIdentifier is present") {
                    let options: [String: Any] = [:]

                    expect {
                        try CommonFunctionality.validatePurchaseParams(options)
                    }.to(throwError())
                }

                it("throws purchaseInvalidError when neither identifier is present") {
                    let options: [String: Any] = [:]

                    do {
                        _ = try CommonFunctionality.validatePurchaseParams(options)
                        fail("Expected error to be thrown")
                    } catch let error as NSError {
                        expect(error.code) == ErrorCode.purchaseInvalidError.rawValue
                        expect(error.domain) == ErrorCode.errorDomain
                    }
                }

                it("throws error when packageIdentifier is not a string") {
                    let options: [String: Any] = ["packageIdentifier": 123]

                    expect {
                        try CommonFunctionality.validatePurchaseParams(options)
                    }.to(throwError())
                }

                it("throws error when productIdentifier is not a string") {
                    let options: [String: Any] = ["productIdentifier": 123]

                    expect {
                        try CommonFunctionality.validatePurchaseParams(options)
                    }.to(throwError())
                }
            }
        }
    }
}
