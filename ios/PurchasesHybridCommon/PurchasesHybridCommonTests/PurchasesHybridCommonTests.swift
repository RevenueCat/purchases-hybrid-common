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
@testable import RevenueCat

class PurchasesHybridCommonTests: QuickSpec {

    private let mockCustomerInfo = try! CustomerInfo(data: [
        "request_date": "2019-08-16T10:30:42Z",
        "subscriber": [
            "first_seen": "2019-07-17T00:05:54Z",
            "original_app_user_id": "",
            "subscriptions": [:],
            "other_purchases": [:]
        ]])

    override func spec() {

        context("proxy url string") {
            it("parses the string and sets the url if valid") {
                let urlString = "https://revenuecat.com"
                CommonFunctionality.proxyURLString = urlString
                expect(Purchases.proxyURL?.absoluteString) == urlString
            }

            it("sets the proxy to nil if null passed in") {
                let urlString = "https://revenuecat.com"
                CommonFunctionality.proxyURLString = urlString
                expect(Purchases.proxyURL).toNot(beNil())

                CommonFunctionality.proxyURLString = nil
                expect(Purchases.proxyURL).to(beNil())
            }

            it("raises exception if proxy can't be parsed") {
                let expectedMessage = "could not set the proxyURL, provided value is not a valid URL: not a valid url"
                self.expectFatalError(expectedMessage: expectedMessage) {
                    CommonFunctionality.proxyURLString = "not a valid url"
                }
            }
        }

        context("logIn") {
            it("passes the call correctly to Purchases") {
                let mockPurchases = MockPurchases()
                let mockCreated = Bool.random()
                mockPurchases.stubbedLogInCompletionResult = (self.mockCustomerInfo, mockCreated, nil)

                Purchases.setDefaultInstance(mockPurchases)

                let appUserID = "appUserID"
                CommonFunctionality.logIn(appUserID: appUserID) { _, _ in }

                expect(mockPurchases.invokedLogInCount) == 1
                expect(mockPurchases.invokedLogInParameters?.appUserID) == appUserID
            }

            it("returns customerInfo and created if successful") {
                let mockPurchases = MockPurchases()
                let mockCreated = Bool.random()
                mockPurchases.stubbedLogInCompletionResult = (self.mockCustomerInfo, mockCreated, nil)

                Purchases.setDefaultInstance(mockPurchases)
                var receivedResultDict: NSDictionary?
                var receivedError: ErrorContainer?

                let appUserID = "appUserID"
                CommonFunctionality.logIn(appUserID: appUserID) { resultDict, error in
                    receivedResultDict = resultDict! as NSDictionary
                    receivedError = error
                }

                // todo: update this once APIs get updated to v4
                let expectedResult: NSDictionary = [
                    "purchaserInfo": self.mockCustomerInfo.dictionary,
                    "created": mockCreated
                ]

                expect(receivedResultDict) == expectedResult
                expect(receivedError).to(beNil())
            }

            it("returns error if not successful") {
                let mockPurchases = MockPurchases()
                let mockError = NSError(domain: "revenuecat", code: 123)

                mockPurchases.stubbedLogInCompletionResult = (nil, false, mockError)

                Purchases.setDefaultInstance(mockPurchases)
                var receivedResultDict: NSDictionary?
                var receivedError: ErrorContainer?

                let appUserID = "appUserID"
                CommonFunctionality.logIn(appUserID: appUserID) { resultDict, error in
                    receivedResultDict = resultDict as NSDictionary?
                    receivedError = error
                }

                let expectedErrorDict: NSDictionary = [
                    "code": mockError.code,
                    "message": mockError.localizedDescription,
                    "underlyingErrorMessage": ""

                ]

                expect(receivedResultDict).to(beNil())
                expect(receivedError).toNot(beNil())
                expect(receivedError!.error as NSError) == mockError
                expect(receivedError!.code) == mockError.code
                expect(receivedError!.message) == mockError.localizedDescription
                expect(receivedError!.info as NSDictionary) == expectedErrorDict
            }
        }

        context("logOut") {
            it("passes the call correctly to Purchases") {
                let mockPurchases = MockPurchases()
                mockPurchases.stubbedLogOutCompletionResult = (self.mockCustomerInfo, nil)

                Purchases.setDefaultInstance(mockPurchases)

                CommonFunctionality.logOut { _, _ in }

                expect(mockPurchases.invokedLogOutCount) == 1
            }

            it("returns customerInfo if successful") {
                let mockPurchases = MockPurchases()
                mockPurchases.stubbedLogOutCompletionResult = (self.mockCustomerInfo, nil)

                Purchases.setDefaultInstance(mockPurchases)
                var receivedResultDict: [String: Any]?
                var receivedError: ErrorContainer?

                CommonFunctionality.logOut { resultDict, error in
                    receivedResultDict = resultDict
                    receivedError = error
                }
                let expectedResultDict: [String: Any] =  self.mockCustomerInfo.dictionary
                let unwrappedReceivedResultDict = try! XCTUnwrap(receivedResultDict)
                expect(unwrappedReceivedResultDict as NSDictionary).to(equal(expectedResultDict as NSDictionary))
                expect(receivedError).to(beNil())
            }

            it("returns error if not successful") {
                let mockPurchases = MockPurchases()
                let mockError = NSError(domain: "revenuecat", code: 123)

                mockPurchases.stubbedLogOutCompletionResult = (nil, mockError)

                Purchases.setDefaultInstance(mockPurchases)
                var receivedResultDict: NSDictionary?
                var receivedError: ErrorContainer?

                CommonFunctionality.logOut { resultDict, error in
                    receivedResultDict = resultDict as NSDictionary?
                    receivedError = error
                }

                let expectedErrorDict: NSDictionary = [
                    "code": mockError.code,
                    "message": mockError.localizedDescription,
                    "underlyingErrorMessage": ""
                ]

                expect(receivedResultDict).to(beNil())
                expect(receivedError).toNot(beNil())
                expect(receivedError!.error as NSError) == mockError
                expect(receivedError!.code) == mockError.code
                expect(receivedError!.message) == mockError.localizedDescription
                expect(receivedError!.info as NSDictionary) == expectedErrorDict
            }
        }

    }
}
