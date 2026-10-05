//
//  PaywallProxyResultHandlerTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Quick
import Nimble
@testable import PurchasesHybridCommonUI

@available(iOS 15.0, *)
class PaywallProxyResultHandlerTests: QuickSpec {

    override func spec() {

        var proxy: PaywallProxy!
        var results: [String]!

        beforeEach {
            proxy = PaywallProxy()
            results = []
        }

        describe("result handler") {

            it("reports an error when there is no view controller to present from") {
                proxy.presentPaywall(options: [:],
                                     purchaseLogicBridge: nil,
                                     paywallResultHandler: { results.append($0) })

                expect(results) == ["ERROR"]
            }

            it("reports an error when the required entitlement identifier is missing") {
                proxy.presentPaywallIfNeeded(options: [:],
                                             purchaseLogicBridge: nil,
                                             paywallResultHandler: { results.append($0) })

                expect(results) == ["ERROR"]
            }

        }

    }

}

#endif
