//
//  PurchasesHybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 5/12/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Quick
import Nimble
import PurchasesHybridCommon


class PurchasesHybridAdditionsTests: QuickSpec {
    override func spec() {
        
        context("configure with platform flavor and version") {
            it("initialize without raising exceptions") {
                expect {
                    Purchases.configure(withAPIKey: "api key",
                                        appUserID: nil,
                                        observerMode: false,
                                        userDefaults: nil,
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        dangerousSettings: nil)
                }.notTo(raiseException())
            }
        }
        context("configure with user defaults suite name") {
            it("initializes without raising exceptions if no suite name is passed") {
                expect {
                    Purchases.configure(withAPIKey: "api key",
                                        appUserID: nil,
                                        observerMode: false,
                                        userDefaultsSuiteName: nil,
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        dangerousSettings: nil)
                }.notTo(raiseException())
            }
            it("initializes without raising exceptions if a suite name is passed") {
                expect {
                    Purchases.configure(withAPIKey: "api key",
                                        appUserID: nil,
                                        observerMode: false,
                                        userDefaultsSuiteName: "test",
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        dangerousSettings: nil)
                }.notTo(raiseException())
            }
        }
        context("configure with dangerous settings") {
            it("initializes without raising exceptions if dangerous settings is passed") {
                expect {
                    Purchases.configure(withAPIKey: "api key",
                                        appUserID: nil,
                                        observerMode: false,
                                        userDefaultsSuiteName: "test",
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3",
                                        dangerousSettings: DangerousSettings(autoSyncPurchases: false))
                }.notTo(raiseException())
            }
        }
    }
}
