//
//  PurchasesHybridCommonTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 6/10/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Quick
import Nimble
@testable import PurchasesHybridCommon

class PurchasesHybridCommonTests: QuickSpec {

    override func spec() {

        context("proxy url string") {
            it("parses the string and sets the url if valid") {
                let urlString = "https://revenuecat.com"
                RCCommonFunctionality.proxyURLString = urlString
                expect(Purchases.proxyURL?.absoluteString) == urlString
            }

            it("sets the proxy to nil if null passed in") {
                let urlString = "https://revenuecat.com"
                RCCommonFunctionality.proxyURLString = urlString
                expect(Purchases.proxyURL).toNot(beNil())

                RCCommonFunctionality.proxyURLString = nil
                expect(Purchases.proxyURL).to(beNil())
            }

            it("raises exception if proxy can't be parsed") {
                expect { RCCommonFunctionality.proxyURLString = "not a valid url" }.to(raiseException())
            }
        }

        context("canMakePayments") {
                    it("passes the call correctly to Purchases") {
                        let mockPurchases = MockPurchases()

                        Purchases.setDefaultInstance(mockPurchases)

                        RCCommonFunctionality.canMakePayments

                        expect { mockPurchases.invokedCanMakePaymentsCount } == 1
                    }
                }

    }
}
