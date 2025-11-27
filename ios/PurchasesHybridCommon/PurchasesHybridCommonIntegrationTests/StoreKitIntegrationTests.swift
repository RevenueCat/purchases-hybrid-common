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

class StoreKit2ObserverModeIntegrationTests: BaseIntegrationTests {

    override class var purchasesAreCompletedBy: PurchasesAreCompletedBy {
        return .myApp
    }

    override class var storeKitVersion: StoreKitVersion { return .storeKit2 }

    func testRecordPurchase() async throws {
        guard let product = try await Product.products(for: [Self.productIdentifier]).first else {
            fail("The product to purchase should not be nil.")
            return
        }
        let purchaseResult = try await product.purchase()
        expect(purchaseResult).toNot(beNil(), description: "The purchase result should not be nil.")

        let (dict, error) = try await withCheckedThrowingContinuation { continuation in
            CommonFunctionality.recordPurchase(productID: Self.productIdentifier) { (dict, error) in
                continuation.resume(returning: (dict, error))
            }

        }
        expect(error).to(
            beNil(),
            description: "The error returned by recordPurchase() should be nil, got \(error.debugDescription)."
        )
        var unwrappedDict = try XCTUnwrap(dict)
        removeDates(&unwrappedDict)
        await self.assertSnapshot(unwrappedDict)
    }

    func testHandleObserverModeTransactionMissingTransaction() async throws {
        let (dict, error) = try await withCheckedThrowingContinuation { continuation in
            CommonFunctionality.recordPurchase(productID: "invalid_product_id") { (dict, error) in
                continuation.resume(returning: (dict, error))
            }
        }
        expect(error?.error).to(matchError(ErrorCode.unknownError))
        expect(dict).to(beNil())
    }
}

class StoreKit1IntegrationTests: BaseIntegrationTests {

    override class func setUp() {
        // Uncomment this to re-record snapshots if necessary:
        // isRecording = true
    }

    override class var storeKitVersion: StoreKitVersion {
        return .storeKit1
    }

    func testCanGetOfferings() async throws {
        let offerings = try await CommonFunctionality.offerings()

        await self.assertSnapshot(offerings)
    }

    func testCanGetCurrentOfferingForPlacement() async throws {
        let onboardingOffering = try await CommonFunctionality.currentOffering(forPlacement: "onboarding")
        let settingsOffering = try await CommonFunctionality.currentOffering(forPlacement: "settings")
        let fallbackOffering = try await CommonFunctionality.currentOffering(forPlacement: "doesnt exist")

        expect(onboardingOffering).to(beNil())
        expect(settingsOffering).notTo(beNil())
        expect(fallbackOffering).notTo(beNil())
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

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func testPurchaseFailuresAreReportedCorrectly() async throws {
        try await self.testSession.setSimulatedError(.purchase(.purchaseNotAllowed), forAPI: .purchase)

        do {
            try await self.purchaseMonthlyOffering()
            fail("Expected error")
        } catch {
            expect(error).to(matchError(ErrorCode.purchaseNotAllowedError))
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

    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *)
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

    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *)
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

    @available(iOS 12.2, macOS 10.14.4, tvOS 12.2, *)
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

    static let entitlementIdentifier = "premium"

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
            presentedOfferingContext: package.presentedOfferingContext.dictionary,
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

internal extension StoreKitVersion {

    var testSuffix: String {
        switch self {
        case .storeKit1: return "SK1"
        case .storeKit2: return "SK2"
        }
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

