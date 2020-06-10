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
        context("configure with user defaults suite name") {
            it("initializes without raising exceptions if no suite name is passed") {
                expect {
                    Purchases.configure(withAPIKey: "api key",
                                        appUserID: nil,
                                        observerMode: false,
                                        userDefaultsSuiteName: nil,
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3")
                }.notTo(raiseException())
            }
            it("initializes without raising exceptions if a suite name is passed") {
                expect {
                    Purchases.configure(withAPIKey: "api key",
                                        appUserID: nil,
                                        observerMode: false,
                                        userDefaultsSuiteName: "test",
                                        platformFlavor: "hybrid-platform",
                                        platformFlavorVersion: "1.2.3")
                }.notTo(raiseException())
            }
        }
        
        context("proxy url string") {
            it("parses the string and sets the url if valid") {
                let urlString = "https://revenuecat.com"
                Purchases.proxyURLString = urlString
                expect(Purchases.proxyURL?.absoluteString) == urlString
            }
            
            it("sets the proxy to nil if null passed in") {
                let urlString = "https://revenuecat.com"
                Purchases.proxyURLString = urlString
                expect(Purchases.proxyURL).toNot(beNil())
                
                Purchases.proxyURLString = nil
                expect(Purchases.proxyURL).to(beNil())
            }
            
            it("raises exception if proxy can't be parsed") {
                expect { Purchases.proxyURLString = "not a valid url" }.to(raiseException())
            }
        }
    }
}
