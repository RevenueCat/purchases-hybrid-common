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

}

private extension StoreKit1IntegrationTests {

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

private extension StoreKit2Setting {

    var testSuffix: String {
        switch self {
        case .disabled, .enabledOnlyForOptimizations: return "SK1"
        case .enabledForCompatibleDevices: return "SK2"
        }
    }

}
