//
//  PurchasesHybridCommonIntegrationTests.swift
//  PurchasesHybridCommonIntegrationTests
//
//  Created by Nacho Soto on 6/27/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import PurchasesHybridCommon

@testable import RevenueCat
import SnapshotTesting
import StoreKitTest
import XCTest

class BaseIntegrationTests: XCTestCase {

    class var storeKitVersion: StoreKitVersion {
        return .default
    }

    class var purchasesAreCompletedBy: PurchasesAreCompletedBy {
        return .revenueCat
    }

    static let productIdentifier = "com.revenuecat.purchases_hybrid_common.monthly_19.99_.1_week_intro"

    internal var testSession: SKTestSession!

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

        // Avoid continuing with potentially bad data after a failed assertion
        // Unless snapshots are being recorded, since we need to record the entire test
        // instead of stopping after the first snapshot is created (which makes the test fail)
        self.continueAfterFailure = isRecording

        guard Constants.apiKey != "REVENUECAT_API_KEY", Constants.proxyURL != "REVENUECAT_PROXY_URL" else {
            throw ErrorUtils.configurationError(message: "Must set configuration in `Constants.swift`")
        }

        UserDefaults(suiteName: Constants.userDefaultsSuiteName)!
            .removePersistentDomain(forName: Constants.userDefaultsSuiteName)

        if !Constants.proxyURL.isEmpty {
            Purchases.proxyURL = URL(string: Constants.proxyURL)
        }

        self.clearReceiptIfExists()

        // Initialize `Purchases` *after* the fresh new session has been created
        // (and transactions has been cleared), to avoid the SDK posting receipts from
        // a previous test.
        self.configurePurchases()

        // SDK initialization begins with an initial request to offerings
        // Which results in a get-create of the initial anonymous user.
        // To avoid race conditions with when this request finishes and make all tests deterministic
        // this waits for that request to finish.
        _ = try await CommonFunctionality.offerings()
    }

    override func tearDown() {
        Purchases.clearSingleton()

        super.tearDown()
    }

    @MainActor
    func assertSnapshot(
        _ value: Any,
        testName: String = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let name = "\(Self.storeKitVersion.testSuffix)-\(testName)"
        SnapshotTesting.assertSnapshot(matching: value,
                                       as: .json,
                                       file: file,
                                       testName: name,
                                       line: line)
    }

}

private extension BaseIntegrationTests {

    func clearReceiptIfExists() {
        let manager = FileManager.default

        guard let url = Bundle.main.appStoreReceiptURL, manager.fileExists(atPath: url.path) else { return }

        do {
            try manager.removeItem(at: url)
        } catch {
            Logger.appleError("Error attempting to remove receipt URL '\(url)': \(error)")
        }
    }

    func configurePurchases() {
        _ = Purchases.configure(
            apiKey: Constants.apiKey,
            appUserID: nil,
            purchasesAreCompletedBy: Self.purchasesAreCompletedBy.name,
            userDefaultsSuiteName: Constants.userDefaultsSuiteName,
            platformFlavor: nil,
            platformFlavorVersion: nil,
            storeKitVersion: Self.storeKitVersion.name,
            dangerousSettings: self.dangerousSettings,
            verificationMode: nil,
            diagnosticsEnabled: false,
            automaticDeviceIdentifierCollectionEnabled: true,
            preferredLocale: nil
        )
        Purchases.logLevel = .debug
    }

    private var dangerousSettings: DangerousSettings {
        return .init(autoSyncPurchases: true,
                     internalSettings: DangerousSettings.Internal(enableReceiptFetchRetry: true))
    }

}
