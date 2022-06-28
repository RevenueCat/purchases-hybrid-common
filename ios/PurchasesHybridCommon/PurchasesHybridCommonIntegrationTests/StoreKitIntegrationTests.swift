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

    override class var storeKit2Setting: StoreKit2Setting { return .enabledForCompatibleDevices }

}

class StoreKit1IntegrationTests: BaseIntegrationTests {

    private var testSession: SKTestSession!

    override class func setUp() {
        // Uncomment this to re-record snapshots if necessary:
        // isRecording = true
    }

    override func setUp() async throws {
        try await super.setUp()

        self.testSession = try SKTestSession(configurationFileNamed: Constants.storeKitConfigFileName)
        self.testSession.resetToDefaultState()
        self.testSession.disableDialogs = true
        self.testSession.clearTransactions()
        if #available(iOS 15.2, *) {
            self.testSession.timeRate = .monthlyRenewalEveryThirtySeconds
        } else {
            self.testSession.timeRate = .oneSecondIsOneDay
        }

        // SDK initialization begins with an initial request to offerings
        // Which results in a get-create of the initial anonymous user.
        // To avoid race conditions with when this request finishes and make all tests deterministic
        // this waits for that request to finish.
        _ = try await CommonFunctionality.offerings()
    }

    override class var storeKit2Setting: StoreKit2Setting {
        return .disabled
    }

    func testCanGetOfferings() async throws {
        let offerings = try await CommonFunctionality.offerings()

        await self.assertSnapshot(offerings)
    }

    func testCanMakePurchase() async throws {
        var data = try await self.purchaseMonthlyOffering()
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
        var customerInfo = try await CommonFunctionality.logIn(appUserID: UUID().uuidString)
        removeDates(&customerInfo)
        await self.assertSnapshot(customerInfo)

        try await self.purchaseMonthlyOffering()

        var loggedOutCustomerInfo = try await CommonFunctionality.logOut()
        removeDates(&loggedOutCustomerInfo)
        await self.assertSnapshot(loggedOutCustomerInfo)
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
        let name = "\(Self.storeKit2Setting.testSuffix)-\(testName)"
        SnapshotTesting.assertSnapshot(matching: value,
                                       as: .json,
                                       file: file,
                                       testName: name,
                                       line: line)
    }

}

private extension StoreKit1IntegrationTests {

    static let entitlementIdentifier = "premium"

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

}

private extension StoreKit2Setting {

    var testSuffix: String {
        switch self {
        case .disabled, .enabledOnlyForOptimizations: return "SK1"
        case .enabledForCompatibleDevices: return "SK2"
        }
    }

}

/// Remove dates from the given dictionary so they can be ignored from snapshot tests.
private func removeDates(_ data: inout [String: Any]) {
    func removeDatesFromAny(_ data: inout Any) {
        guard var dictionary = data as? [String: Any] else {
            return
        }

        removeDates(&dictionary)
        data = dictionary
    }

    func shouldRemove(key: String, withValue value: Any?) -> Bool {
        let keysToRemove: Set<String> = [
            "millis",
            "date",
            "firstSeen",
            "originalAppUserId"
        ]

        return (!keysToRemove.allSatisfy { !key.localizedCaseInsensitiveContains($0) } &&
                value != nil &&
                !(value is NSNull))
    }

    for var entry in data {
        if shouldRemove(key: entry.key, withValue: entry.value) {
            data.removeValue(forKey: entry.key)
        } else {
            removeDatesFromAny(&entry.value)
            data[entry.key] = entry.value
        }
    }
}
