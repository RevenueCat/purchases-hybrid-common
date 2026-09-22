//
//  PaywallProxyDelegateRoutingTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Quick
import Nimble
import RevenueCatUI
import UIKit
@testable import PurchasesHybridCommonUI

@available(iOS 15.0, *)
private final class PaywallDelegateSpy: NSObject, PaywallViewControllerDelegateWrapper {

    var startedPurchases: [PaywallViewController] = []

    func paywallViewControllerDidStartPurchase(_ controller: PaywallViewController) {
        self.startedPurchases.append(controller)
    }

}

@available(iOS 15.0, *)
class PaywallProxyDelegateRoutingTests: QuickSpec {

    override func spec() {

        var proxy: PaywallProxy!
        var proxyWideDelegate: PaywallDelegateSpy!
        var firstDelegate: PaywallDelegateSpy!
        var secondDelegate: PaywallDelegateSpy!
        var firstController: PaywallViewController!
        var secondController: PaywallViewController!

        beforeEach {
            proxy = PaywallProxy()
            proxyWideDelegate = PaywallDelegateSpy()
            firstDelegate = PaywallDelegateSpy()
            secondDelegate = PaywallDelegateSpy()
            proxy.delegate = proxyWideDelegate
            firstController = PaywallViewController(displayCloseButton: false,
                                                    dismissRequestedHandler: { _ in })
            secondController = PaywallViewController(displayCloseButton: false,
                                                     dismissRequestedHandler: { _ in })
        }

        describe("delegate routing") {

            it("sends a presentation's events only to its own delegate") {
                proxy.delegateByVC[firstController] = firstDelegate
                proxy.delegateByVC[secondController] = secondDelegate

                proxy.paywallViewControllerDidStartPurchase(firstController)

                expect(firstDelegate.startedPurchases) == [firstController]
                expect(secondDelegate.startedPurchases).to(beEmpty())
                expect(proxyWideDelegate.startedPurchases).to(beEmpty())
            }

            it("falls back to the proxy-wide delegate when the presentation has none") {
                proxy.paywallViewControllerDidStartPurchase(firstController)

                expect(proxyWideDelegate.startedPurchases) == [firstController]
            }

            it("keeps a live presentation routed when another one is dismissed") {
                proxy.delegateByVC[firstController] = firstDelegate
                proxy.delegateByVC[secondController] = secondDelegate

                proxy.paywallViewControllerWasDismissed(secondController)
                proxy.paywallViewControllerDidStartPurchase(firstController)

                expect(firstDelegate.startedPurchases) == [firstController]
                expect(secondDelegate.startedPurchases).to(beEmpty())
            }

            it("stops routing to a delegate once its presentation is dismissed") {
                proxy.delegateByVC[firstController] = firstDelegate

                proxy.paywallViewControllerWasDismissed(firstController)
                proxy.paywallViewControllerDidStartPurchase(firstController)

                expect(firstDelegate.startedPurchases).to(beEmpty())
                expect(proxyWideDelegate.startedPurchases) == [firstController]
            }

            it("follows the presentation onto its exit offer controller") {
                proxy.delegateByVC[firstController] = firstDelegate

                proxy.paywallViewController(firstController,
                                            willPresentExitOfferController: secondController)
                proxy.paywallViewControllerDidStartPurchase(secondController)

                expect(firstDelegate.startedPurchases) == [secondController]
                expect(proxyWideDelegate.startedPurchases).to(beEmpty())
            }

        }

    }

}

#endif
