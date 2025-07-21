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
@_spi(Internal) @testable import RevenueCat
import Foundation

class PurchasesHybridCommonTests: QuickSpec {

    private static let mockCustomerInfo = try! CustomerInfo.fromJSON(
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

    override func spec() {
        var mockPurchases: MockPurchases!

        beforeEach {
            mockPurchases = .init()
            CommonFunctionality.sharedInstance = mockPurchases
        }

        afterEach {
            // Fixme: This can be replaced with `Purchases.restoreLogHandler()`
            // when is released https://github.com/RevenueCat/purchases-ios/pull/2699
            Logger.internalLogHandler = Logger.defaultLogHandler
        }


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
                let mockCreated = Bool.random()
                mockPurchases.stubbedLogInCompletionResult = (Self.mockCustomerInfo, mockCreated, nil)

                let appUserID = "appUserID"
                CommonFunctionality.logIn(appUserID: appUserID) { _, _ in }

                expect(mockPurchases.invokedLogInCount) == 1
                expect(mockPurchases.invokedLogInParameters?.appUserID) == appUserID
            }

            it("returns customerInfo and created if successful") {
                let mockCreated = Bool.random()
                mockPurchases.stubbedLogInCompletionResult = (Self.mockCustomerInfo, mockCreated, nil)

                var receivedResultDict: NSDictionary?
                var receivedError: ErrorContainer?

                let appUserID = "appUserID"
                CommonFunctionality.logIn(appUserID: appUserID) { resultDict, error in
                    receivedResultDict = resultDict! as NSDictionary
                    receivedError = error
                }

                // todo: update this once APIs get updated to v4
                let expectedResult: NSDictionary = [
                    "customerInfo": Self.mockCustomerInfo.dictionary,
                    "created": mockCreated
                ]

                expect(receivedResultDict) == expectedResult
                expect(receivedError).to(beNil())
            }

            it("returns error if not successful") {
                let mockError = NSError(domain: "revenuecat", code: 123)

                mockPurchases.stubbedLogInCompletionResult = (nil, false, mockError)

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
                let unwrappedReceivedError = try XCTUnwrap(receivedError)
                expect(unwrappedReceivedError.error as NSError) == mockError
                expect(unwrappedReceivedError.code) == mockError.code
                expect(unwrappedReceivedError.message) == mockError.localizedDescription
                expect(unwrappedReceivedError.info as NSDictionary) == expectedErrorDict
            }
        }

        context("logOut") {
            it("passes the call correctly to Purchases") {
                mockPurchases.stubbedLogOutCompletionResult = (Self.mockCustomerInfo, nil)

                CommonFunctionality.logOut { _, _ in }

                expect(mockPurchases.invokedLogOutCount) == 1
            }

            it("returns customerInfo if successful") {
                mockPurchases.stubbedLogOutCompletionResult = (Self.mockCustomerInfo, nil)

                var receivedResultDict: [String: Any]?
                var receivedError: ErrorContainer?

                CommonFunctionality.logOut { resultDict, error in
                    receivedResultDict = resultDict
                    receivedError = error
                }
                let expectedResultDict: [String: Any] =  Self.mockCustomerInfo.dictionary
                let unwrappedReceivedResultDict = try! XCTUnwrap(receivedResultDict)
                expect(unwrappedReceivedResultDict as NSDictionary).to(equal(expectedResultDict as NSDictionary))
                expect(receivedError).to(beNil())
            }

            it("returns error if not successful") {
                let mockError = NSError(domain: "revenuecat", code: 123)

                mockPurchases.stubbedLogOutCompletionResult = (nil, mockError)

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
                let unwrappedReceivedError = try XCTUnwrap(receivedError)
                expect(unwrappedReceivedError.error as NSError) == mockError
                expect(unwrappedReceivedError.code) == mockError.code
                expect(unwrappedReceivedError.message) == mockError.localizedDescription
                expect(unwrappedReceivedError.info as NSDictionary) == expectedErrorDict
            }
        }

        context("beginRefundRequest") {
            if #available(iOS 15.0, *) {
                context("productId") {
                    it("passes the call correctly to Purchases") {
                        CommonFunctionality.beginRefundRequest(productId: "mock-product-id") { _ in }

                        expect(mockPurchases.invokedBeginRefundRequestForProductCount) == 1
                        expect(mockPurchases.invokedBeginRefundRequestForProductParameters?.productId)
                        == "mock-product-id"
                    }

                    it("does not return an error if successful") {
                        var completionCallCount = 0
                        var completionError: ErrorContainer? = nil

                        CommonFunctionality.beginRefundRequest(productId: "mock-product-id") { error in
                            completionCallCount += 1
                            completionError = error
                        }
                        mockPurchases.invokedBeginRefundRequestForProductParameters?.1(.success(.success))

                        expect(completionCallCount) == 1
                        expect(completionError).to(beNil())
                    }

                    it("returns an error with userCancelled extra info set to true") {
                        var completionCallCount = 0
                        var completionError: ErrorContainer? = nil

                        CommonFunctionality.beginRefundRequest(productId: "mock-product-id") { error in
                            completionCallCount += 1
                            completionError = error
                        }
                        mockPurchases.invokedBeginRefundRequestForProductParameters?.1(.success(.userCancelled))

                        expect(completionCallCount) == 1
                        expect(completionError).toNot(beNil())
                        expect(completionError?.info["userCancelled"] as? Bool) == true
                        expect(completionError?.message) == "User cancelled refund request."
                    }

                    it("returns an error if request failed") {
                        var completionCallCount = 0
                        var completionError: ErrorContainer? = nil

                        CommonFunctionality.beginRefundRequest(productId: "mock-product-id") { error in
                            completionCallCount += 1
                            completionError = error
                        }
                        mockPurchases.invokedBeginRefundRequestForProductParameters?.1(.success(.error))

                        expect(completionCallCount) == 1
                        expect(completionError).toNot(beNil())
                        expect(completionError?.message) == "Error during refund request."
                    }
                }

                context("entitlementId") {
                    it("passes the call correctly to Purchases") {
                        CommonFunctionality.beginRefundRequest(entitlementId: "mock-entitlement-id") { _ in }

                        expect(mockPurchases.invokedBeginRefundRequestForEntitlementCount) == 1
                        expect(mockPurchases.invokedBeginRefundRequestForEntitlementParameters?
                            .entitlementId) == "mock-entitlement-id"
                    }

                    it("does not return an error if successful") {
                        var completionCallCount = 0
                        var completionError: ErrorContainer? = nil

                        CommonFunctionality.beginRefundRequest(entitlementId: "mock-entitlement-id") { error in
                            completionCallCount += 1
                            completionError = error
                        }
                        mockPurchases.invokedBeginRefundRequestForEntitlementParameters?.1(.success(.success))

                        expect(completionCallCount) == 1
                        expect(completionError).to(beNil())
                    }

                    it("returns an error with userCancelled extra info set to true") {
                        var completionCallCount = 0
                        var completionError: ErrorContainer? = nil

                        CommonFunctionality.beginRefundRequest(entitlementId: "mock-entitlement-id") { error in
                            completionCallCount += 1
                            completionError = error
                        }
                        mockPurchases.invokedBeginRefundRequestForEntitlementParameters?.1(.success(.userCancelled))

                        expect(completionCallCount) == 1
                        expect(completionError).toNot(beNil())
                        expect(completionError?.info["userCancelled"] as? Bool) == true
                        expect(completionError?.message) == "User cancelled refund request."
                    }

                    it("returns an error if request failed") {
                        var completionCallCount = 0
                        var completionError: ErrorContainer? = nil

                        CommonFunctionality.beginRefundRequest(entitlementId: "mock-entitlement-id") { error in
                            completionCallCount += 1
                            completionError = error
                        }
                        mockPurchases.invokedBeginRefundRequestForEntitlementParameters?.1(.success(.error))

                        expect(completionCallCount) == 1
                        expect(completionError).toNot(beNil())
                        expect(completionError?.message) == "Error during refund request."
                    }
                }

                context("forActiveEntitlement") {
                    it("passes the call correctly to Purchases") {
                        CommonFunctionality.beginRefundRequestForActiveEntitlement { _ in }

                        expect(mockPurchases.invokedBeginRefundRequestForActiveEntitlementCount) == 1
                    }

                    it("does not return an error if successful") {
                        var completionCallCount = 0
                        var completionError: ErrorContainer? = nil

                        CommonFunctionality.beginRefundRequestForActiveEntitlement { error in
                            completionCallCount += 1
                            completionError = error
                        }
                        mockPurchases.invokedBeginRefundRequestForActiveEntitlementParameter?(.success(.success))

                        expect(completionCallCount) == 1
                        expect(completionError).to(beNil())
                    }

                    it("returns an error with userCancelled extra info set to true") {
                        var completionCallCount = 0
                        var completionError: ErrorContainer? = nil

                        CommonFunctionality.beginRefundRequestForActiveEntitlement { error in
                            completionCallCount += 1
                            completionError = error
                        }
                        mockPurchases.invokedBeginRefundRequestForActiveEntitlementParameter?(.success(.userCancelled))

                        expect(completionCallCount) == 1
                        expect(completionError).toNot(beNil())
                        expect(completionError?.info["userCancelled"] as? Bool) == true
                        expect(completionError?.message) == "User cancelled refund request."
                    }

                    it("returns an error if request failed") {
                        var completionCallCount = 0
                        var completionError: ErrorContainer? = nil

                        CommonFunctionality.beginRefundRequestForActiveEntitlement { error in
                            completionCallCount += 1
                            completionError = error
                        }
                        mockPurchases.invokedBeginRefundRequestForActiveEntitlementParameter?(.success(.error))

                        expect(completionCallCount) == 1
                        expect(completionError).toNot(beNil())
                        expect(completionError?.message) == "Error during refund request."
                    }
                }
            }
        }

        context("setLogLevel") {
            for level in LogLevel.levels {
                it("sets level to \(level)") {
                    CommonFunctionality.setLogLevel(level.description)
                    expect(Purchases.logLevel) == level
                }
            }
        }

        context("setLogHandler") {
            let expectedMessage = "a message"
            for level in LogLevel.levels {
                it("\(level) logs work") {
                    CommonFunctionality.setLogHander(onLogReceived: { logDetails in
                        expect(logDetails["logLevel"]) == level.description.uppercased()
                        expect(logDetails["message"]) == expectedMessage
                    })
                    Purchases.logHandler(level, expectedMessage)
                }
            }
        }

        context("getVirtualCurrencies") {
            it("calls Purchases.getVirtualCurrencies with VirtualCurrencies on success") {
                var completionCallCount = 0
                var completionVirtualCurrencies: NSDictionary?
                var completionError: ErrorContainer? = nil

                let virtualCurrencies = VirtualCurrencies(virtualCurrencies: [
                    "COIN": VirtualCurrency(
                        balance: 1,
                        name: "Coin",
                        code: "COIN",
                        serverDescription: nil
                    )
                ])

                mockPurchases.getVirtualCurrenciesStub = .success(virtualCurrencies)

                let expectedVirtualCurrenciesDictionary: NSDictionary = [
                    "all": [
                        "COIN": [
                            "balance": 1,
                            "name": "Coin",
                            "code": "COIN",
                            "serverDescription": nil
                        ]
                    ]
                ]

                CommonFunctionality.getVirtualCurrencies { rcDictionary, error in
                    guard let rcDictionary else {
                        fail("rcDictionary must not be nil")
                        return
                    }

                    completionCallCount += 1
                    completionVirtualCurrencies = NSDictionary(dictionary: rcDictionary)
                    completionError = error
                }

                expect(mockPurchases.invokedGetVirtualCurrencies).to(beTrue())
                expect(mockPurchases.invokedGetVirtualCurrenciesCount).to(equal(1))
                expect(completionCallCount).to(equal(1))
                expect(completionVirtualCurrencies).to(equal(expectedVirtualCurrenciesDictionary))

                expect(completionError).to(beNil())
            }

            it("calls Purchases.getVirtualCurrencies with ErrorContainer on error") {
                var completionCallCount = 0
                var completionVirtualCurrencies: NSDictionary? = nil
                var completionError: ErrorContainer? = nil

                let mockError = NSError(domain: "revenuecat", code: 123)
                let expectedErrorDict: NSDictionary = [
                    "code": mockError.code,
                    "message": mockError.localizedDescription,
                    "underlyingErrorMessage": ""
                ]
                mockPurchases.getVirtualCurrenciesStub = .failure(mockError)

                CommonFunctionality.getVirtualCurrencies { rcDictionary, error in
                    expect(rcDictionary).to(beNil())

                    if let rcDictionary {
                        completionVirtualCurrencies = NSDictionary(dictionary: rcDictionary)
                    } else {
                        completionVirtualCurrencies = nil
                    }

                    completionCallCount += 1
                    completionError = error
                }

                expect(mockPurchases.invokedGetVirtualCurrencies).to(beTrue())
                expect(mockPurchases.invokedGetVirtualCurrenciesCount).to(equal(1))
                expect(completionCallCount).to(equal(1))
                expect(completionVirtualCurrencies).to(beNil())

                let unwrappedReceivedError = try XCTUnwrap(completionError)
                expect(unwrappedReceivedError.error as NSError) == mockError
                expect(unwrappedReceivedError.code) == mockError.code
                expect(unwrappedReceivedError.message) == mockError.localizedDescription
                expect(unwrappedReceivedError.info as NSDictionary) == expectedErrorDict
            }
        }

        context("invalidateVirtualCurrencyCache") {
            it("calls Purchases.invalidateVirtualCurrencyCache") {
                CommonFunctionality.invalidateVirtualCurrenciesCache()
                expect(mockPurchases.invokedInvalidateVirtualCurrenciesCache).to(beTrue())
                expect(mockPurchases.invokedInvalidateVirtualCurrenciesCacheCount).to(equal(1))
            }
        }

        context("getCachedVirtualCurrencies") {
            it("calls Purchases.cachedVirtualCurrencies") {
                let expectedCode = "COIN"
                let expectedName = "Coin"
                let expectedBalance = 1
                let expectedServerDescription: String? = nil

                let expectedVirtualCurrenciesDictionary: NSDictionary = [
                    "all": [
                        expectedCode: [
                            "balance": expectedBalance,
                            "name": expectedName,
                            "code": expectedCode,
                            "serverDescription": expectedServerDescription as Any
                        ]
                    ]
                ]

                let cachedVirtualCurrencies = CommonFunctionality.getCachedVirtualCurrencies()
                expect(cachedVirtualCurrencies).to(beNil())

                let virtualCurrencies = VirtualCurrencies(virtualCurrencies: [
                    expectedCode: VirtualCurrency(
                        balance: expectedBalance,
                        name: expectedName,
                        code: expectedCode,
                        serverDescription: expectedServerDescription
                    )
                ])

                mockPurchases.cachedVirtualCurrencies = virtualCurrencies

                let cachedVirtualCurrencies2 = CommonFunctionality.getCachedVirtualCurrencies()
                expect(cachedVirtualCurrencies2).toNot(beNil())

                expect(NSDictionary(dictionary: cachedVirtualCurrencies2!)).to(equal(expectedVirtualCurrenciesDictionary))
            }
        }
    }
}
