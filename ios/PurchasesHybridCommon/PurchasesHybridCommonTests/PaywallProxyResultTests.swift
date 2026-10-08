//
//  PaywallProxyResultTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Quick
import Nimble
@testable import PurchasesHybridCommonUI

@available(iOS 15.0, *)
class PaywallProxyResultTests: QuickSpec {

    override func spec() {

        describe("presentPaywallIfNeeded") {

            it("reports an error when the required entitlement identifier is missing") {
                var results: [String] = []

                PaywallProxy().presentPaywallIfNeeded(options: [:],
                                                      purchaseLogicBridge: nil,
                                                      delegate: nil,
                                                      paywallResultHandler: { results.append($0) })

                expect(results) == ["ERROR"]
            }

        }

    }

}

#endif
