//
//  CommonFunctionality+PurchaseTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Antonio Rico Diez on 30/9/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Quick
import Foundation
import StoreKit
import StoreKitTest
import XCTest
import Nimble
@_spi(Internal) @testable import PurchasesHybridCommon
@_spi(Internal) @testable import RevenueCat

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

            context("introductory offer eligibility on unsupported products") {
                it("does not fall back to purchasing a StoreKit 1 or Test Store product") {
                    let sk1Product = SKProduct()
                    sk1Product.setValue("test_product", forKey: "productIdentifier")
                    let products = [
                        StoreProduct(sk1Product: sk1Product),
                        TestStoreProduct(localizedTitle: "Test", price: 1, currencyCode: "USD", localizedPriceString: "$1",
                                         productIdentifier: "test_product", productType: .autoRenewableSubscription,
                                         localizedDescription: "Test", locale: Locale(identifier: "en_US")).toStoreProduct()
                    ]
                    for product in products {
                        let mockPurchases = MockPurchases()
                        CommonFunctionality.sharedInstance = mockPurchases
                        var receivedError: ErrorContainer?
                        CommonFunctionality.purchase(options: ["productIdentifier": "test_product"],
                                                     introductoryOfferEligibilityJWS: "header.deny-intro.signature") {
                            _, error in receivedError = error
                        }
                        mockPurchases.invokedProductsParameters?.completion([product])
                        expect(receivedError?.code) == ErrorCode.unsupportedError.rawValue
                        expect(mockPurchases.invokedPurchaseProductCount) == 0
                        expect(mockPurchases.invokedPurchaseParamsCompletionCount) == 0
                    }
                }
            }

            context("package lookup") {
                var mockPurchases: MockPurchases!

                beforeEach {
                    mockPurchases = MockPurchases()
                    CommonFunctionality.sharedInstance = mockPurchases
                }

                func purchasePackage(offeringsResult: (Offerings?, PublicError?)) -> ErrorContainer? {
                    let options: [String: Any] = [
                        "packageIdentifier": "$rc_monthly",
                        "presentedOfferingContext": ["offeringIdentifier": "default"]
                    ]
                    var receivedError: ErrorContainer?

                    CommonFunctionality.purchase(options: options) { _, error in
                        receivedError = error
                    }
                    mockPurchases.invokedOfferingsParameters?.completion(offeringsResult.0, offeringsResult.1)

                    return receivedError
                }

                it("forwards the offerings error") {
                    let receivedError = purchasePackage(offeringsResult: (nil, ErrorCode.networkError as NSError))

                    expect(receivedError?.code) == ErrorCode.networkError.rawValue
                    expect(mockPurchases.invokedPurchasePackageCount) == 0
                }

                it("forwards the offerings error when purchasing with a win-back offer") {
                    var receivedError: ErrorContainer?

                    CommonFunctionality.purchase(package: "$rc_monthly",
                                                 presentedOfferingContext: ["offeringIdentifier": "default"],
                                                 winBackOfferID: "win_back_offer") { _, error in
                        receivedError = error
                    }
                    mockPurchases.invokedOfferingsParameters?.completion(nil, ErrorCode.networkError as NSError)

                    expect(receivedError?.code) == ErrorCode.networkError.rawValue
                }

                it("reports a missing package when offerings load without it") {
                    let receivedError = purchasePackage(offeringsResult: (nil, nil))

                    expect(receivedError?.code) == ErrorCode.productNotAvailableForPurchaseError.rawValue
                    expect(receivedError?.message).to(contain("Couldn't find package"))
                    expect(mockPurchases.invokedPurchasePackageCount) == 0
                }
            }
        }
    }
}

// Uses local StoreKit products and a mocked Purchases boundary. No backend or signing credentials are needed.
#if compiler(>=6.1)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
final class IntroductoryOfferEligibilityPurchaseTests: XCTestCase {

    private var session: SKTestSession!
    private var purchases: MockPurchases!
    private var product: StoreProduct!
    private let token = "header.deny-intro.signature"

    override func setUp() async throws {
        try await super.setUp()
        guard #available(iOS 15.0, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) else {
            throw XCTSkip("Introductory offer eligibility JWS is unsupported on this OS.")
        }
        self.session = try SKTestSession(configurationFileNamed: "PurchasesHybridCommon")
        self.session.resetToDefaultState()
        self.purchases = MockPurchases()
        CommonFunctionality.sharedInstance = self.purchases
        let products = try await Product.products(for: [Self.productIdentifier])
        self.product = StoreProduct(sk2Product: try XCTUnwrap(products.first))
    }

    @MainActor
    func testForwardsTokenForProductAndPreservesNativeErrors() async throws {
        var receivedError: ErrorContainer?
        CommonFunctionality.purchase(options: ["productIdentifier": Self.productIdentifier],
                                     introductoryOfferEligibilityJWS: self.token) { _, error in
            receivedError = error
        }
        self.purchases.invokedProductsParameters?.completion([self.product])
        let invocation = try XCTUnwrap(self.purchases.invokedPurchaseParamsCompletionParameters)
        XCTAssertEqual(invocation.params.introductoryOfferEligibilityJWS, self.token)
        XCTAssertEqual(invocation.params.product, self.product)
        invocation.completion(nil, nil, ErrorCode.purchaseInvalidError as NSError, false)
        XCTAssertEqual(receivedError?.code, ErrorCode.purchaseInvalidError.rawValue)
        XCTAssertEqual(self.purchases.invokedPurchaseProductCount, 0)
    }

    func testForwardsTokenAndOfferingContextForPackage() throws {
        let context: [String: Any] = ["offeringIdentifier": "default", "placementIdentifier": "onboarding"]
        CommonFunctionality.purchase(options: [
            "packageIdentifier": "$rc_monthly",
            "presentedOfferingContext": context,
            "introductoryOfferEligibilityJWS": self.token
        ]) { _, _ in }
        self.purchases.invokedOfferingsParameters?.completion(self.offerings(product: self.product), nil)
        let params = try XCTUnwrap(self.purchases.invokedPurchaseParamsCompletionParameters?.params)
        XCTAssertEqual(params.introductoryOfferEligibilityJWS, self.token)
        XCTAssertEqual(params.package?.identifier, "$rc_monthly")
        XCTAssertEqual(params.package?.presentedOfferingContext.offeringIdentifier, "default")
        XCTAssertEqual(params.package?.presentedOfferingContext.placementIdentifier, "onboarding")
        XCTAssertEqual(self.purchases.invokedPurchasePackageCount, 0)
    }

    func testDoesNotPurchaseUnsupportedPackage() {
        let product = TestStoreProduct(localizedTitle: "Test", price: 1, currencyCode: "USD", localizedPriceString: "$1",
                                       productIdentifier: Self.productIdentifier, productType: .autoRenewableSubscription,
                                       localizedDescription: "Test", locale: Locale(identifier: "en_US")).toStoreProduct()
        var receivedError: ErrorContainer?
        CommonFunctionality.purchase(options: [
            "packageIdentifier": "$rc_monthly",
            "presentedOfferingContext": ["offeringIdentifier": "default"],
            "introductoryOfferEligibilityJWS": self.token
        ]) { _, error in receivedError = error }
        self.purchases.invokedOfferingsParameters?.completion(self.offerings(product: product), nil)
        XCTAssertEqual(receivedError?.code, ErrorCode.unsupportedError.rawValue)
        XCTAssertEqual(self.purchases.invokedPurchasePackageCount, 0)
        XCTAssertEqual(self.purchases.invokedPurchaseParamsCompletionCount, 0)
    }

    private func offerings(product: StoreProduct) -> Offerings {
        let package = Package(identifier: "$rc_monthly", packageType: .monthly, storeProduct: product,
                              offeringIdentifier: "default", webCheckoutUrl: nil)
        let offering = Offering(identifier: "default", serverDescription: "Default", metadata: [:],
                                availablePackages: [package], webCheckoutUrl: nil)
        return Offerings(offerings: ["default": offering], currentOfferingID: "default", placements: nil,
                         targeting: nil,
                         contents: Offerings.Contents(
                            response: OfferingsResponse(currentOfferingId: "default", offerings: [], placements: nil,
                                                       targeting: nil, uiConfig: nil),
                            httpResponseOriginalSource: HTTPResponseOriginalSource(isFallbackUrlResponse: false,
                                                                                  isLoadShedderResponse: false)),
                         loadedFromDiskCache: false)
    }

    private static let productIdentifier =
        "com.revenuecat.purchases_hybrid_common.monthly_19.99_.1_week_intro"
}

#endif

// MARK: - Mock Transaction Helper
final class MockStoreTransaction: StoreTransactionType {
    let productIdentifier: String
    let purchaseDate: Date
    let transactionIdentifier: String
    let quantity: Int
    let storefront: RevenueCat.Storefront?
    let jwsRepresentation: String?
    let environment: StoreEnvironment?
    let hasKnownPurchaseDate: Bool
    let hasKnownTransactionIdentifier: Bool
    let reason: RevenueCat.TransactionReason?
    let revocationDate: Date?
    let revocationReason: RevenueCat.RevocationReason?

    init(
        productIdentifier: String,
        purchaseDate: Date,
        transactionIdentifier: String = UUID().uuidString,
        quantity: Int = 1,
        storefront: RevenueCat.Storefront? = nil,
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
        self.revocationDate = nil
        self.revocationReason = nil
    }

    func finish(_ wrapper: PaymentQueueWrapperType, completion: @escaping @Sendable () -> Void) {
        completion()
    }
}
