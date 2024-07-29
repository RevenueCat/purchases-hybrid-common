//
//  PurchasesAreCompletedByHybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Will Taylor on 7/26/24.
//  Copyright © 2024 RevenueCat. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import PurchasesHybridCommon
@testable import RevenueCat

class PurchasesAreCompletedByHybridAdditionsTests: QuickSpec {

    override func spec() {
        context("PurchasesAreCompletedBy") {
            expect(PurchasesAreCompletedBy(name: "MY_APP")).to(equal(.myApp))
            expect(PurchasesAreCompletedBy(name: "REVENUECAT")).to(equal(.revenueCat))
            expect(PurchasesAreCompletedBy(name: "FAIL")).to(beNil())
        }
    }
}
