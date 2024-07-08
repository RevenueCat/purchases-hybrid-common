//
//  PurchasesHybridCommonIntegrationTests.swift
//  PurchasesHybridCommonIntegrationTests
//
//  Created by Nacho Soto on 6/27/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

@testable import RevenueCat
import SnapshotTesting
import XCTest

class BaseIntegrationTests: XCTestCase {

    class var storeKitVersion: StoreKitVersion {
        return .default
    }

    class var purchasesAreCompletedBy: PurchasesAreCompletedBy {
        return .revenueCat
    }

    override func setUp() async throws {
        try await super.setUp()

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
        self.configurePurchases()
    }

    override func tearDown() {
        Purchases.clearSingleton()

        super.tearDown()
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
            purchasesAreCompletedBy: Self.purchasesAreCompletedBy,
            userDefaultsSuiteName: Constants.userDefaultsSuiteName,
            platformFlavor: nil,
            platformFlavorVersion: nil,
            storeKitVersion: Self.storeKitVersion.name,
            dangerousSettings: self.dangerousSettings
        )
        Purchases.logLevel = .debug
    }

    private var dangerousSettings: DangerousSettings {
        return .init(autoSyncPurchases: true,
                     internalSettings: DangerousSettings.Internal(enableReceiptFetchRetry: true))
    }

}
