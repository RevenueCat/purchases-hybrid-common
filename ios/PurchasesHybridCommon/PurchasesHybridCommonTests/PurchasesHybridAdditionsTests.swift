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
                                        platformFlavorVersion: "1.2.3")
                    
                }.notTo(raiseException())
            }
        }
    }
}
