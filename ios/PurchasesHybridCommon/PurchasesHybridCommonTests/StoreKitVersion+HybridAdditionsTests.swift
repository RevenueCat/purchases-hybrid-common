//
//  StoreKitVersionHybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Mark Villacampa on 23/2/24.
//  Copyright © 2024 RevenueCat. All rights reserved.
//

import Quick
import Nimble
@testable import PurchasesHybridCommon
@testable import RevenueCat

class StoreKitVersionHybridAdditionsTests: QuickSpec {

    override func spec() {
        context("StoreKitVersion") {
            expect(StoreKitVersion(name: "DEFAULT")).to(equal(.storeKit2))
            expect(StoreKitVersion(name: "STOREKIT_1")).to(equal(.storeKit1))
            expect(StoreKitVersion(name: "STOREKIT_2")).to(equal(.storeKit2))
            expect(StoreKitVersion(name: "FAIL")).to(beNil())
        }
    }
}
