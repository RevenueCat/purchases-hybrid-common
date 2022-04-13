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
import PurchasesHybridCommonSwift

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
                let mockCreated = Bool.random()
                mockPurchases.stubbedLogInCompletionResult = (mockPurchaserInfo, mockCreated, nil)

                Purchases.setDefaultInstance(mockPurchases)

                let appUserID = "appUserID"
                RCCommonFunctionality.logIn(withAppUserID: appUserID) { _, _ in }

                expect { mockPurchases.invokedLogInCount } == 1
                expect { mockPurchases.invokedLogInParameters?.appUserID } == appUserID
            }

            it("returns purchaserInfo and created if successful") {
                let mockPurchases = MockPurchases()
                let mockPurchaserInfo = PartialMockPurchaserInfo()
                let mockCreated = Bool.random()
                mockPurchases.stubbedLogInCompletionResult = (mockPurchaserInfo, mockCreated, nil)

                Purchases.setDefaultInstance(mockPurchases)
                var receivedResultDict: NSDictionary?
                var receivedError: ErrorContainer?

                let appUserID = "appUserID"
                RCCommonFunctionality.logIn(withAppUserID: appUserID) { resultDict, error in
                    receivedResultDict = resultDict! as NSDictionary
                    receivedError = error
                }

                let expectedResult: NSDictionary = [
                    "purchaserInfo": mockPurchaserInfo.dictionary() as NSDictionary,
                    "created": mockCreated
                ]

                expect { receivedResultDict } == expectedResult
                expect { receivedError }.to(beNil())
            }

            it("returns error if not successful") {
                let mockPurchases = MockPurchases()
                let mockError = NSError(domain: "revenuecat", code: 123)

                mockPurchases.stubbedLogInCompletionResult = (nil, false, mockError)

                Purchases.setDefaultInstance(mockPurchases)
                var receivedResultDict: NSDictionary?
                var receivedError: ErrorContainer?

                let appUserID = "appUserID"
                RCCommonFunctionality.logIn(withAppUserID: appUserID) { resultDict, error in
                    receivedResultDict = resultDict as NSDictionary?
                    receivedError = error
                }

                let expectedErrorDict: NSDictionary = [
                    "code": mockError.code,
                    "message": mockError.localizedDescription,
                    "underlyingErrorMessage": ""

                ]

                expect { receivedResultDict }.to(beNil())
                expect { receivedError }.toNot(beNil())
                expect { receivedError!.error as NSError } == mockError
                expect { receivedError!.code } == mockError.code
                expect { receivedError!.message } == mockError.localizedDescription
                expect { receivedError!.info as NSDictionary } == expectedErrorDict
            }
        }

        context("logOut") {
            it("passes the call correctly to Purchases") {
                let mockPurchases = MockPurchases()
                let mockPurchaserInfo = PartialMockPurchaserInfo()
                mockPurchases.stubbedLogOutCompletionResult = (mockPurchaserInfo, nil)

                Purchases.setDefaultInstance(mockPurchases)

                RCCommonFunctionality.logOut { _, _ in }

                expect { mockPurchases.invokedLogOutCount } == 1
            }

            it("returns purchaserInfo if successful") {
                let mockPurchases = MockPurchases()
                let mockPurchaserInfo = PartialMockPurchaserInfo()
                mockPurchases.stubbedLogOutCompletionResult = (mockPurchaserInfo, nil)

                Purchases.setDefaultInstance(mockPurchases)
                var receivedResultDict: NSDictionary?
                var receivedError: ErrorContainer?

                RCCommonFunctionality.logOut { resultDict, error in
                    receivedResultDict = resultDict! as NSDictionary
                    receivedError = error
                }
                expect { receivedResultDict } == mockPurchaserInfo.dictionary() as NSDictionary
                expect { receivedError }.to(beNil())
            }

            it("returns error if not successful") {
                let mockPurchases = MockPurchases()
                let mockError = NSError(domain: "revenuecat", code: 123)

                mockPurchases.stubbedLogOutCompletionResult = (nil, mockError)

                Purchases.setDefaultInstance(mockPurchases)
                var receivedResultDict: NSDictionary?
                var receivedError: ErrorContainer?

                RCCommonFunctionality.logOut { resultDict, error in
                    receivedResultDict = resultDict as NSDictionary?
                    receivedError = error
                }

                let expectedErrorDict: NSDictionary = [
                    "code": mockError.code,
                    "message": mockError.localizedDescription,
                    "underlyingErrorMessage": ""
                ]

                expect { receivedResultDict }.to(beNil())
                expect { receivedError }.toNot(beNil())
                expect { receivedError!.error as NSError } == mockError
                expect { receivedError!.code } == mockError.code
                expect { receivedError!.message } == mockError.localizedDescription
                expect { receivedError!.info as NSDictionary } == expectedErrorDict
            }
        }
        
    }
}
