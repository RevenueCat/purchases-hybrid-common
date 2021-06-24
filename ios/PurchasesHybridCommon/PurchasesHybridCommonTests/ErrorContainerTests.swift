//
//  ErrorContainerTests.swift
//  PurchasesHybridCommonTests
//
//  Created by César de la Vega on 6/11/21.
//  Copyright © 2021 RevenueCat. All rights reserved.
//

import Quick
import Nimble
import PurchasesHybridCommon
import Purchases

class ErrorContainerTests: QuickSpec {

    override func spec() {
        context("error code") {
            it("contains the error code") {
                let error = Purchases.ErrorUtils.missingAppUserIDError() as NSError
                let errorContainer = RCErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.code) == error.code
            }
            it("info dictionary contains the error code") {
                let error = Purchases.ErrorUtils.missingAppUserIDError() as NSError
                let errorContainer = RCErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.info["code"] as? Int) == error.code
            }
        }

        context("error message") {
            it("contains the error message") {
                let error = Purchases.ErrorUtils.missingAppUserIDError()
                let errorContainer = RCErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.message) == error.localizedDescription
            }
            it("info dictionary contains the error message") {
                let error = Purchases.ErrorUtils.missingAppUserIDError()
                let errorContainer = RCErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.info["message"] as? String) == error.localizedDescription
            }
        }

        context("error") {
            it("contains the error itself") {
                let error = Purchases.ErrorUtils.missingAppUserIDError() as NSError
                let errorContainer = RCErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.error as NSError) == error
            }
        }

        context("underlying error") {
            it("info dictionary contains the underlying error message") {
                let skError = NSError(
                        domain: SKErrorDomain,
                        code: 2,
                        userInfo: [
                            NSLocalizedDescriptionKey: "underlying error message",
                        ]
                )
                let error = Purchases.ErrorUtils.purchasesError(withSKError: skError)
                let errorContainer = RCErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.info["underlyingErrorMessage"] as? String) == skError.localizedDescription
            }
            it("info dictionary contains empty underlying error message if no underlying error") {
                let error = Purchases.ErrorUtils.missingAppUserIDError()
                let errorContainer = RCErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.info["underlyingErrorMessage"] as? String) == ""
            }
        }

        context("readable error code") {
            it("info dictionary contains the readable error code in both keys") {
                let error = Purchases.ErrorUtils.missingAppUserIDError() as NSError
                let errorContainer = RCErrorContainer(error: error, extraPayload: [:])

                let readableErrorKey = error.userInfo[Purchases.ReadableErrorCodeKey] as? String
                expect(readableErrorKey).toNot(beNil())
                expect(readableErrorKey) != ""
                expect(errorContainer.info["readableErrorCode"] as? String) == readableErrorKey
                expect(errorContainer.info["readable_error_code"] as? String) == readableErrorKey
            }
        }
    }
}
