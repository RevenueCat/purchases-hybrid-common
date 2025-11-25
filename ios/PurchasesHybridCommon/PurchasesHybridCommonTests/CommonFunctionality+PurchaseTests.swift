//
//  CommonFunctionality+PurchaseTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Antonio Rico Diez on 30/9/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Quick
import Nimble
@testable import PurchasesHybridCommon
@testable import RevenueCat

class CommonFunctionalityPurchaseTests: QuickSpec {

    override func spec() {
        describe("purchase with options") {
            context("error handling") {
                it("returns error when neither packageIdentifier nor productIdentifier is present") {
                    let options: [String: Any] = [:]
                    var receivedError: ErrorContainer?
                    var receivedResult: [String: Any]?

                    CommonFunctionality.purchase(options: options) { result, error in
                        receivedResult = result
                        receivedError = error
                    }

                    expect(receivedResult).to(beNil())
                    expect(receivedError).toNot(beNil())
                    expect(receivedError?.code) == ErrorCode.purchaseInvalidError.rawValue
                }

                it("returns purchaseInvalidError when packageIdentifier is provided without presentedOfferingContext") {
                    let options: [String: Any] = ["packageIdentifier": "test_package"]
                    var receivedError: ErrorContainer?
                    var receivedResult: [String: Any]?

                    CommonFunctionality.purchase(options: options) { result, error in
                        receivedResult = result
                        receivedError = error
                    }

                    expect(receivedResult).to(beNil())
                    expect(receivedError).toNot(beNil())
                    expect(receivedError?.code) == ErrorCode.purchaseInvalidError.rawValue
                    expect(receivedError?.message).to(contain("presentedOfferingContext"))
                }

                it("returns error when packageIdentifier is not a string") {
                    let options: [String: Any] = [
                        "packageIdentifier": 123,
                        "presentedOfferingContext": ["offering_id": "test"]
                    ]
                    var receivedError: ErrorContainer?
                    var receivedResult: [String: Any]?

                    CommonFunctionality.purchase(options: options) { result, error in
                        receivedResult = result
                        receivedError = error
                    }

                    expect(receivedResult).to(beNil())
                    expect(receivedError).toNot(beNil())
                    expect(receivedError?.code) == ErrorCode.purchaseInvalidError.rawValue
                }

                it("returns error when productIdentifier is not a string") {
                    let options: [String: Any] = ["productIdentifier": 123]
                    var receivedError: ErrorContainer?
                    var receivedResult: [String: Any]?

                    CommonFunctionality.purchase(options: options) { result, error in
                        receivedResult = result
                        receivedError = error
                    }

                    expect(receivedResult).to(beNil())
                    expect(receivedError).toNot(beNil())
                    expect(receivedError?.code) == ErrorCode.purchaseInvalidError.rawValue
                }
            }

            context("successful purchases") {
                var mockPurchases: MockPurchases!
                let mockCustomerInfo = try! CustomerInfo.fromJSON(
                    """
                    {
                        "request_date": "2019-08-16T10:30:42Z",
                        "subscriber": {
                            "first_seen": "2019-07-17T00:05:54Z",
                            "original_app_user_id": "test_user",
                            "subscriptions": {},
                            "other_purchases": {}
                        }
                    }
                    """
                )

                beforeEach {
                    mockPurchases = MockPurchases()
                    CommonFunctionality.sharedInstance = mockPurchases
                }

                it("successfully purchases a product") {
                    let testProduct = TestStoreProduct(
                        localizedTitle: "Test Product",
                        price: 9.99,
                        localizedPriceString: "$9.99",
                        productIdentifier: "test_product_id",
                        productType: .autoRenewableSubscription,
                        localizedDescription: "Test product description"
                    )
                    let storeProduct = testProduct.toStoreProduct()

                    let mockTransaction = StoreTransaction(
                        MockStoreTransaction(
                            productIdentifier: "test_product_id",
                            purchaseDate: Date()
                        )
                    )

                    let options: [String: Any] = ["productIdentifier": "test_product_id"]
                    var receivedResult: [String: Any]?
                    var receivedError: ErrorContainer?

                    waitUntil(timeout: .seconds(2)) { done in
                        CommonFunctionality.purchase(options: options) { result, error in
                            receivedResult = result
                            receivedError = error
                            done()
                        }

                        mockPurchases.invokedProductsParameters?.completion([storeProduct])

                        DispatchQueue.main.async {
                            if let purchaseParams = mockPurchases.invokedPurchaseProductParameters {
                                purchaseParams.completion(mockTransaction, mockCustomerInfo, nil, false)
                            }
                        }
                    }

                    expect(receivedError).to(beNil())
                    expect(receivedResult).toNot(beNil())
                    expect(receivedResult?["productIdentifier"] as? String) == "test_product_id"
                    expect(mockPurchases.invokedPurchaseProductCount) == 1
                }

                it("successfully purchases a package") {
                    let testProduct = TestStoreProduct(
                        localizedTitle: "Monthly Package",
                        price: 9.99,
                        localizedPriceString: "$9.99",
                        productIdentifier: "monthly_product_id",
                        productType: .autoRenewableSubscription,
                        localizedDescription: "Monthly subscription"
                    )

                    // Create mock offering and package
                    let storeProduct = testProduct.toStoreProduct()
                    let mockPackage = Package(
                        identifier: "$rc_monthly",
                        packageType: .monthly,
                        storeProduct: storeProduct,
                        offeringIdentifier: "default",
                        webCheckoutUrl: nil
                    )

                    let mockOffering = Offering(
                        identifier: "default",
                        serverDescription: "Default offering",
                        metadata: [:],
                        availablePackages: [mockPackage],
                        webCheckoutUrl: nil
                    )

                    let mockOfferings = Offerings(
                        offerings: ["default": mockOffering],
                        currentOfferingID: "default",
                        placements: nil,
                        targeting: nil,
                        contents: Offerings.Contents(response: OfferingsResponse(currentOfferingId: "default",
                                                                                 offerings: [],
                                                                                 placements: nil,
                                                                                 targeting: nil,
                                                                                 uiConfig: nil),
                                                     httpResponseOriginalSource: HTTPResponseOriginalSource(isFallbackUrlResponse: false,
                                                                                                            isLoadShedderResponse: false)),
                        loadedFromDiskCache: false,
                    )

                    let mockTransaction = StoreTransaction(
                        MockStoreTransaction(
                            productIdentifier: "monthly_product_id",
                            purchaseDate: Date()
                        )
                    )

                    let presentedOfferingContext = [
                        "offeringIdentifier": "default",
                        "placementIdentifier": "placement_id"
                    ]
                    let options: [String: Any] = [
                        "packageIdentifier": "$rc_monthly",
                        "presentedOfferingContext": presentedOfferingContext
                    ]
                    var receivedResult: [String: Any]?
                    var receivedError: ErrorContainer?

                    waitUntil(timeout: .seconds(2)) { done in
                        CommonFunctionality.purchase(options: options) { result, error in
                            receivedResult = result
                            receivedError = error
                            done()
                        }

                        mockPurchases.invokedOfferingsParameters?.completion(mockOfferings, nil)

                        let presentedOfferingContext = mockPurchases.invokedPurchasePackageParameters?.package.presentedOfferingContext
                        expect(presentedOfferingContext?.offeringIdentifier) == "default"
                        expect(presentedOfferingContext?.placementIdentifier) == "placement_id"
                        expect(presentedOfferingContext?.targetingContext).to(beNil())

                        // Simulate the purchase completion
                        DispatchQueue.main.async {
                            if let purchaseParams = mockPurchases.invokedPurchasePackageParameters {
                                purchaseParams.completion(mockTransaction, mockCustomerInfo, nil, false)
                            }
                        }
                    }

                    expect(receivedError).to(beNil())
                    expect(receivedResult).toNot(beNil())
                    expect(receivedResult?["productIdentifier"] as? String) == "monthly_product_id"
                    expect(mockPurchases.invokedPurchasePackageCount) == 1
                }
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
    }

    func finish(_ wrapper: PaymentQueueWrapperType, completion: @escaping @Sendable () -> Void) {
        completion()
    }
}
