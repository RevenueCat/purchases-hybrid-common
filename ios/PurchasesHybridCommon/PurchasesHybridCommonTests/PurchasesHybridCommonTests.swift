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
        
        context("logIn") {
            it("passes the call correctly to Purchases") {
                let mockPurchases = MockPurchases()
                let mockPurchaserInfo = PartialMockPurchaserInfo()
                let mockCreated = true
                mockPurchases.stubbedLogInCompletionResult = (mockPurchaserInfo, mockCreated, nil)

                Purchases.setDefaultInstance(mockPurchases)
                var receivedResultDict: NSDictionary?
                var receivedError: RCErrorContainer?
                
                RCCommonFunctionality.log(in: "appUserID") { resultDict, error in
                    receivedResultDict = resultDict! as NSDictionary
                    receivedError = error
                }
                
                expect { mockPurchases.invokedLogInErrorCount } == 1
                
                expect { receivedResultDict }.toNot(beNil())
                expect { receivedResultDict!.allKeys.count } == 2
                let receivedPurchaserInfoDict = receivedResultDict!["purchaserInfo"] as! NSDictionary
                expect { receivedPurchaserInfoDict } == mockPurchaserInfo.dictionary() as NSDictionary
                expect { receivedResultDict!["created"]! as! Bool } == mockCreated
                expect { receivedError }.to(beNil())
            }
        }
    }
}
