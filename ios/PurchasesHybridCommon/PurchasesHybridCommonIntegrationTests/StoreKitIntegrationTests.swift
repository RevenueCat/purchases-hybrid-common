//
//  BaseStoreKitIntegrationTests.swift
//  PurchasesHybridCommonIntegrationTests
//
//  Created by Nacho Soto on 6/27/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import PurchasesHybridCommon

import Nimble
@testable import RevenueCat
import SnapshotTesting
import StoreKit
import StoreKitTest
import XCTest

class StoreKit2IntegrationTests: StoreKit1IntegrationTests {

    override class var storeKitVersion: StoreKitVersion { return .storeKit2 }

}

class StoreKit2ObserverModeIntegrationTests: StoreKit2IntegrationTests {

    override class var observerMode: Bool { true }

    func testHandleObserverMoveTransaction() async throws {
        _ = try await Product.products(for: [Self.productIdentifier]).first?.purchase()

        let (dict, error) = try await withCheckedThrowingContinuation { continuation in
            CommonFunctionality.handleObserverModeTransaction(productID: Self.productIdentifier) { (dict, error) in
                continuation.resume(returning: (dict, error))
            }
        }
        expect(error).to(beNil())
        var unwrappedDict = try XCTUnwrap(dict)
        removeDates(&unwrappedDict)
        await self.assertSnapshot(unwrappedDict)
    }

}

class StoreKit1IntegrationTests: BaseIntegrationTests {

    private var testSession: SKTestSession!

    override class func setUp() {
        // Uncomment this to re-record snapshots if necessary:
        // isRecording = true
    }

    override func setUp() async throws {
        self.testSession = try SKTestSession(configurationFileNamed: Constants.storeKitConfigFileName)
        self.testSession.resetToDefaultState()
        self.testSession.disableDialogs = true
        self.testSession.clearTransactions()
        if #available(iOS 15.2, *) {
            self.testSession.timeRate = .monthlyRenewalEveryThirtySeconds
        } else {
            self.testSession.timeRate = .oneSecondIsOneDay
        }

        // Initialize `Purchases` *after* the fresh new session has been created
        // (and transactions has been cleared), to avoid the SDK posting receipts from
        // a previous test.
        try await super.setUp()

        // SDK initialization begins with an initial request to offerings
        // Which results in a get-create of the initial anonymous user.
        // To avoid race conditions with when this request finishes and make all tests deterministic
        // this waits for that request to finish.
        _ = try await CommonFunctionality.offerings()
    }

    override class var storeKitVersion: StoreKitVersion {
        return .storeKit1
    }

    func testCanGetOfferings() async throws {
        let offerings = try await CommonFunctionality.offerings()

        await self.assertSnapshot(offerings)
    }

    func testCanPurchasePackage() async throws {
        var data = try await self.purchaseMonthlyOffering()
        removeDates(&data)

        await self.assertSnapshot(data)
    }

    func testCanPurchaseProduct() async throws {
        var data = try await self.purchase(productIdentifier: Self.productIdentifier)
        removeDates(&data)

        await self.assertSnapshot(data)
    }

    func testPurchaseFailuresAreReportedCorrectly() async throws {
        self.testSession.failTransactionsEnabled = true
        self.testSession.failureError = .invalidSignature

        do {
            try await self.purchaseMonthlyOffering()
            fail("Expected error")
        } catch {
            expect(error).to(matchError(ErrorCode.invalidPromotionalOfferError))
        }
    }

    func testLogInAndLogOut() async throws {
        // Since the receipt might not be available on device on the first run,
        // Fetch receipt to make sure there aren't race conditions dependent on the order of test runs.
        _ = try await CommonFunctionality.restorePurchases()

        var customerInfo = try await CommonFunctionality.logIn(appUserID: UUID().uuidString)
        removeDates(&customerInfo)
        await self.assertSnapshot(customerInfo)

        try await self.purchaseMonthlyOffering()

        var loggedOutCustomerInfo = try await CommonFunctionality.logOut()
        removeDates(&loggedOutCustomerInfo)
        await self.assertSnapshot(loggedOutCustomerInfo)
    }

    func testTrialOrIntroductoryPriceEligibility() async throws {
        if Self.storeKitVersion == .storeKit1 {
            // SK1 implementation relies on the receipt being loaded already.
            // See `TrialOrIntroPriceEligibilityChecker.sk1CheckEligibility`
            _ = try await CommonFunctionality.restorePurchases()
        }

        let product = try await self.monthlyPackage.storeProduct

        let result = await CommonFunctionality.checkTrialOrIntroductoryPriceEligibility(for: [product.productIdentifier])

        await self.assertSnapshot(result)
    }

    func testIneligibleForPromotionalOfferByDefault() async {
        do {
            _ = try await CommonFunctionality.promotionalOffer(
                for: Self.productIdentifier,
                discountIdentifier: Self.discountIdentifier
            )

            fail("Expected error")
        } catch {
            expect(error).to(matchError(ErrorCode.ineligibleError))
        }
    }

    func testPromotionalOffer() async throws {
        try await self.purchaseMonthlyOffering()
        try self.testSession.expireSubscription(productIdentifier: Self.productIdentifier)

        var result = try await CommonFunctionality.promotionalOffer(
            for: Self.productIdentifier,
            discountIdentifier: Self.discountIdentifier
        )

        removeVaryingPromotionalOfferData(from: &result)
        await self.assertSnapshot(result)
    }

    func testIneligibleForPromotionalError() async throws {
        do {
            _ = try await CommonFunctionality.promotionalOffer(
                for: Self.productIdentifier,
                discountIdentifier: Self.discountIdentifier
            )
            fail("Expected error")
        } catch {
            expect(error).to(matchError(ErrorCode.ineligibleError))
        }
    }

}

private extension StoreKit1IntegrationTests {

    @MainActor
    func assertSnapshot(
        _ value: Any,
        testName: String = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let name = "SK\(Self.storeKitVersion.debugDescription)-\(testName)"
        SnapshotTesting.assertSnapshot(matching: value,
                                       as: .json,
                                       file: file,
                                       testName: name,
                                       line: line)
    }

}

private extension StoreKit1IntegrationTests {

    static let entitlementIdentifier = "premium"
    static let productIdentifier = "com.revenuecat.purchases_hybrid_common.monthly_19.99_.1_week_intro"

    static let discountIdentifier = "com.revenuecat.purchases_hybrid_common.monthly_19.99.discount"

    private var currentOffering: Offering {
        get async throws {
            return try await XCTAsyncUnwrap(try await Purchases.shared.offerings().current)
        }
    }

    var monthlyPackage: Package {
        get async throws {
            return try await XCTAsyncUnwrap(try await self.currentOffering.monthly)
        }
    }


    @discardableResult
    func purchaseMonthlyOffering(
        file: FileString = #file,
        line: UInt = #line
    ) async throws -> [String: Any] {
        let package = try await self.monthlyPackage

        return try await CommonFunctionality.purchase(
            package: package.identifier,
            offeringIdentifier: package.offeringIdentifier,
            signedDiscountTimestamp: nil
        )
    }

    @discardableResult
    func purchase(
        productIdentifier: String,
        file: FileString = #file,
        line: UInt = #line
    ) async throws -> [String: Any] {
        return try await CommonFunctionality.purchase(
            product: productIdentifier,
            signedDiscountTimestamp: nil
        )
    }

}

/// Remove dates from the given dictionary so they can be ignored from snapshot tests.
private func removeDates(_ data: inout [String: Any]) {
    removeNonConstantData(
        from: &data,
        keysToRemove: [
            "millis",
            "date",
            "firstSeen",
            "originalAppUserId"
        ]
    )
}

private func removeVaryingPromotionalOfferData(from data: inout [String: Any]) {
    removeNonConstantData(
        from: &data,
        keysToRemove: [
            "nonce",
            "signature",
            "timestamp"
        ]
    )
}

/// Remove changing data from the given dictionary so they can be ignored from snapshot tests.
private func removeNonConstantData(from data: inout [String: Any], keysToRemove: Set<String>) {
    func removeFromAny(_ data: inout Any) {
        guard var dictionary = data as? [String: Any] else {
            return
        }

        removeNonConstantData(from: &dictionary, keysToRemove: keysToRemove)
        data = dictionary
    }

    func shouldRemove(key: String, withValue value: Any?) -> Bool {
        return (!keysToRemove.allSatisfy { !key.localizedCaseInsensitiveContains($0) } &&
                value != nil &&
                !(value is NSNull))
    }

    for var entry in data {
        if shouldRemove(key: entry.key, withValue: entry.value) {
            data.removeValue(forKey: entry.key)
        } else {
            removeFromAny(&entry.value)
            data[entry.key] = entry.value
        }
    }
}

