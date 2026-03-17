//
//  StoreTransaction+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by RevenueCat.
//  Copyright © 2024 RevenueCat. All rights reserved.
//

import Quick
import Nimble
@testable import PurchasesHybridCommon
@testable import RevenueCat

class StoreTransactionHybridAdditionsTests: QuickSpec {
    override func spec() {
        describe("dictionary") {
            it("includes purchaseToken as nil") {
                let mockTransaction = StoreTransaction(
                    MockStoreTransaction(
                        productIdentifier: "test_product_id",
                        purchaseDate: Date(timeIntervalSince1970: 1000),
                        transactionIdentifier: "test_transaction_id"
                    )
                )

                let dictionary = mockTransaction.dictionary

                expect(dictionary["purchaseToken"]).to(beNil())
                expect(dictionary.keys).to(contain("purchaseToken"))
                expect(dictionary["transactionIdentifier"] as? String) == "test_transaction_id"
                expect(dictionary["productIdentifier"] as? String) == "test_product_id"
                expect(dictionary["purchaseDateMillis"]).toNot(beNil())
                expect(dictionary["purchaseDate"]).toNot(beNil())
            }
        }
    }
}

// MARK: - Mock Transaction Helper
private final class MockStoreTransaction: StoreTransactionType {
    let productIdentifier: String
    let purchaseDate: Date
    let transactionIdentifier: String
    let quantity: Int
    let storefront: Storefront?
    let jwsRepresentation: String?
    let environment: StoreEnvironment?
    let hasKnownPurchaseDate: Bool
    let hasKnownTransactionIdentifier: Bool
    let reason: RevenueCat.TransactionReason?

    init(
        productIdentifier: String,
        purchaseDate: Date,
        transactionIdentifier: String = UUID().uuidString,
        quantity: Int = 1,
        storefront: Storefront? = nil,
        jwsRepresentation: String? = nil,
        environment: StoreEnvironment? = nil
    ) {
        self.productIdentifier = productIdentifier
        self.purchaseDate = purchaseDate
        self.transactionIdentifier = transactionIdentifier
        self.quantity = quantity
        self.storefront = storefront
        self.jwsRepresentation = jwsRepresentation
        self.environment = environment
        self.hasKnownPurchaseDate = true
        self.hasKnownTransactionIdentifier = true
        self.reason = nil
    }

    func finish(_ wrapper: PaymentQueueWrapperType, completion: @escaping @Sendable () -> Void) {
        completion()
    }
}
