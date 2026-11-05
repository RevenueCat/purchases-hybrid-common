//
//  CommonFunctionality+SpendVirtualCurrenciesTests.swift
//  PurchasesHybridCommonTests
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import XCTest
import Nimble
@_spi(Internal) @testable import PurchasesHybridCommon
@_spi(Internal) @testable import RevenueCat

final class CommonFunctionalitySpendVirtualCurrenciesTests: XCTestCase {

    private var mockPurchases: MockPurchases!

    override func setUp() {
        super.setUp()
        self.mockPurchases = MockPurchases()
        CommonFunctionality.sharedInstance = self.mockPurchases
    }

    func testPassesAmountsAndReferenceToPurchases() {
        CommonFunctionality.spendVirtualCurrencies(amounts: ["GLD": 5, "SLV": 10], reference: "order-1") { _, _ in }

        expect(self.mockPurchases.invokedSpendVirtualCurrenciesParameters?.amounts) == ["GLD": 5, "SLV": 10]
        expect(self.mockPurchases.invokedSpendVirtualCurrenciesParameters?.reference) == "order-1"
    }

    func testPassesNilReference() {
        CommonFunctionality.spendVirtualCurrencies(amounts: ["GLD": 5], reference: nil) { _, _ in }

        expect(self.mockPurchases.invokedSpendVirtualCurrenciesCount) == 1
        expect(self.mockPurchases.invokedSpendVirtualCurrenciesParameters?.reference).to(beNil())
    }

    func testConvertsWholeNumberDoubles() {
        let amounts: [String: Any] = ["GLD": NSNumber(value: 5.0), "SLV": NSNumber(value: Int64(10))]

        CommonFunctionality.spendVirtualCurrencies(amounts: amounts, reference: nil) { _, _ in }

        expect(self.mockPurchases.invokedSpendVirtualCurrenciesParameters?.amounts) == ["GLD": 5, "SLV": 10]
    }

    func testPassesNonPositiveAmountsThroughForTheSDKToIgnore() {
        CommonFunctionality.spendVirtualCurrencies(amounts: ["GLD": 0, "SLV": -3], reference: nil) { _, _ in }

        expect(self.mockPurchases.invokedSpendVirtualCurrenciesParameters?.amounts) == ["GLD": 0, "SLV": -3]
    }

    func testRejectsFractionalAmounts() {
        self.expectRejected(["GLD": 1.5])
    }

    func testRejectsNonNumericAmounts() {
        self.expectRejected(["GLD": "5"])
    }

    func testRejectsBooleanAmounts() {
        self.expectRejected(["GLD": true])
    }

    func testSuccessReturnsVirtualCurrenciesDictionary() {
        let virtualCurrencies = VirtualCurrencies(virtualCurrencies: [
            "GLD": VirtualCurrency(balance: 95, name: "Gold", code: "GLD", serverDescription: nil)
        ])
        self.mockPurchases.spendVirtualCurrenciesStub = .success(virtualCurrencies)
        var result: [String: Any]?
        var error: ErrorContainer?

        CommonFunctionality.spendVirtualCurrencies(amounts: ["GLD": 5], reference: nil) {
            result = $0
            error = $1
        }

        expect(result.map { NSDictionary(dictionary: $0) }) == NSDictionary(dictionary: virtualCurrencies.rc_dictionary)
        expect(error).to(beNil())
    }

    func testNativeErrorIsReturned() {
        let nativeError = NSError(domain: ErrorCode.errorDomain, code: ErrorCode.unsupportedError.rawValue)
        self.mockPurchases.spendVirtualCurrenciesStub = .failure(nativeError)
        var result: [String: Any]?
        var error: ErrorContainer?

        CommonFunctionality.spendVirtualCurrencies(amounts: ["GLD": 5], reference: nil) {
            result = $0
            error = $1
        }

        expect(result).to(beNil())
        expect(error?.error) == nativeError
    }

    private func expectRejected(_ amounts: [String: Any], file: FileString = #file, line: UInt = #line) {
        var error: ErrorContainer?

        CommonFunctionality.spendVirtualCurrencies(amounts: amounts, reference: nil) { error = $1 }

        expect(file: file, line: line, error?.code) == ErrorCode.purchaseInvalidError.rawValue
        expect(file: file, line: line, self.mockPurchases.invokedSpendVirtualCurrencies) == false
    }

}
