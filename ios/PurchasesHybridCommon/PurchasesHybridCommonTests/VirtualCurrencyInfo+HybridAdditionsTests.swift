//
//  VirtualCurrencyInfo+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Will Taylor on 3/27/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import PurchasesHybridCommon
@testable import RevenueCat

class VirtualCurrencyInfoHybridAdditionsTests: QuickSpec {
    override func spec() {
        describe("rc_dictionary") {
            it("has the right format") {
                let expectedBalance: Int64 = 100
                let customerInfoResponse = CustomerInfoResponse.VirtualCurrencyInfo(balance: expectedBalance)
                let virtualCurrencyInfo = VirtualCurrencyInfo(with: customerInfoResponse)

                guard let receivedDictionary = virtualCurrencyInfo.rc_dictionary as? [String: NSObject] else {
                    fatalError("received rc_dictionary is not in the right format")
                }

                expect(receivedDictionary["balance"] as? Int64) == 100
            }
        }
    }
}
