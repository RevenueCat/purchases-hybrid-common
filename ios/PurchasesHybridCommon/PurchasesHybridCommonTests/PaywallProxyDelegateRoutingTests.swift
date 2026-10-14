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
@testable import RevenueCat

@available(iOS 15.0, *)
private final class PaywallDelegateSpy: NSObject, PaywallViewControllerDelegateWrapper {

    var startedPurchases: [PaywallViewController] = []
    var completedTransactions: [[String: Any]?] = []

    func paywallViewControllerDidStartPurchase(_ controller: PaywallViewController) {
        self.startedPurchases.append(controller)
    }

    func paywallViewController(_ controller: PaywallViewController,
                               didFinishPurchasingWith customerInfoDictionary: [String: Any],
                               transaction transactionDictionary: [String: Any]?) {
        self.completedTransactions.append(transactionDictionary)
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

        describe("purchase completed") {

            let customerInfo = try! CustomerInfo.fromJSON(
                """
                {
                    "request_date": "2019-08-16T10:30:42Z",
                    "subscriber": {
                        "first_seen": "2019-07-17T00:05:54Z",
                        "original_app_user_id": "",
                        "subscriptions": {},
                        "other_purchases": {}
                    }
                }
                """
            )

            it("forwards a purchase with a transaction") {
                let transaction = StoreTransaction(
                    MockStoreTransaction(productIdentifier: "product",
                                         purchaseDate: Date(timeIntervalSince1970: 1000),
                                         transactionIdentifier: "transaction")
                )

                proxy.paywallViewController(firstController,
                                            didFinishPurchasingWith: customerInfo,
                                            transaction: transaction)

                expect(proxyWideDelegate.completedTransactions.map { $0?["transactionIdentifier"] as? String })
                    == ["transaction"]
            }

            it("does not forward a purchase without a transaction") {
                proxy.paywallViewController(firstController,
                                            didFinishPurchasingWith: customerInfo,
                                            transaction: nil)

                expect(proxyWideDelegate.completedTransactions).to(beEmpty())
            }

        }

    }

}

#endif
