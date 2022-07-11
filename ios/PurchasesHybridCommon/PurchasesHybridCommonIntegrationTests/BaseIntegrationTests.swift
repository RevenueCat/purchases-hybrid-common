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

    class var storeKit2Setting: StoreKit2Setting {
        return .default
    }

    override class func setUp() {
         BundleSandboxEnvironmentDetector.default = MockSandboxEnvironmentDetector()
    }

    override func setUp() async throws {
        try await super.setUp()

        // Avoid continuing with potentially bad data after a failed assertion
        // Unless snapshots are being recorded, since we need to record the entire test
        // instead of stopping after the first snapshot is created (which makes the test fail)
        self.continueAfterFailure = isRecording

        guard Constants.apiKey != "REVENUECAT_API_KEY", Constants.proxyURL != "REVENUECAT_PROXY_URL" else {
            XCTFail("Must set configuration in `Constants.swift`")
            throw ErrorCode.configurationError
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
            Logger.appleWarning("Error attempting to remove receipt URL '\(url)': \(error)")
        }
    }

    func configurePurchases() {
        _ = Purchases.configure(apiKey: Constants.apiKey,
                            appUserID: nil,
                            observerMode: false,
                            userDefaultsSuiteName: Constants.userDefaultsSuiteName,
                            platformFlavor: nil,
                            platformFlavorVersion: nil,
                            usesStoreKit2IfAvailable: Self.storeKit2Setting == .enabledForCompatibleDevices,
                            dangerousSettings: nil)
        Purchases.logLevel = .debug
    }

}

private final class MockSandboxEnvironmentDetector: SandboxEnvironmentDetector {

    let isSandbox: Bool = true

}
