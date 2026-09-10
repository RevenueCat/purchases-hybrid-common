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
@testable import RevenueCat
import StoreKit

class ErrorContainerTests: QuickSpec {

    override func spec() {
        context("error code") {
            it("contains the error code") {
                let error = ErrorUtils.missingAppUserIDError() as NSError
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.code) == error.code
            }
            it("info dictionary contains the error code") {
                let error = ErrorUtils.missingAppUserIDError() as NSError
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.info["code"] as? Int) == error.code
            }
        }

        context("error message") {
            it("contains the error message") {
                let error = ErrorUtils.missingAppUserIDError()
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.message) == error.localizedDescription
            }
            it("info dictionary contains the error message") {
                let error = ErrorUtils.missingAppUserIDError()
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.info["message"] as? String) == error.localizedDescription
            }
        }

        context("error") {
            it("contains the error itself") {
                let error = ErrorUtils.missingAppUserIDError() as NSError
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])
                let containedError = errorContainer.error as NSError

                expect(containedError.code) == error.code
                expect(containedError.domain) == error.domain
                expect(containedError.localizedDescription) == error.localizedDescription
                for (key, value) in error.userInfo {
                    expect(error.userInfo[key] as? String) == value as? String
                }
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
                let error = ErrorUtils.purchasesError(withSKError: skError)
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.info["underlyingErrorMessage"] as? String) == skError.localizedDescription
            }
            it("info dictionary contains empty underlying error message if no underlying error") {
                let error = ErrorUtils.missingAppUserIDError()
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.info["underlyingErrorMessage"] as? String) == ""
            }
        }

        context("readable error code") {
            it("info dictionary contains the readable error code in both keys") {
                let error = ErrorUtils.missingAppUserIDError() as NSError
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])

                let readableErrorKey = error.userInfo["readable_error_code"] as? String
                expect(readableErrorKey).toNot(beNil())
                expect(readableErrorKey) != ""
                expect(errorContainer.info["readableErrorCode"] as? String) == readableErrorKey
                expect(errorContainer.info["readable_error_code"] as? String) == readableErrorKey
            }
            it("forwards the error untouched") {
                let error = ErrorUtils.missingAppUserIDError() as NSError
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])

                expect(errorContainer.error) === error
            }
        }

        context("store error") {
            it("info dictionary contains the store error if found") {
                let skError = NSError(
                    domain: SKErrorDomain,
                    code: 2,
                    userInfo: [
                        NSLocalizedDescriptionKey: "underlying error message",
                    ]
                )
                let error = ErrorUtils.purchasesError(withSKError: skError)
                let errorContainer = ErrorContainer(error: error, extraPayload: [:])

                let storeError = errorContainer.info["storeError"] as? [String: Any]
                expect(storeError).toNot(beNil())
                expect(storeError!["code"] as? Int) == 2
                expect(storeError!["domain"] as? String) == "SKErrorDomain"
                expect(storeError!["message"] as? String) == "underlying error message"
            }
        }
    }
}

// A separate spec because ErrorContainerTests.spec() is already at swiftlint's
// function_body_length limit.
class ErrorContainerPayloadTests: QuickSpec {

    // Every hybrid consumes this payload: react-native-purchases merges it into the
    // rejected NSError, capacitor sends it as the reject data, and cordova, flutter and
    // unity forward it as-is. Dropping a key here breaks all five, and only flutter,
    // cordova and unity would notice without a JS-side normalizer.
    override func spec() {
        it("always carries the keys hybrids consume") {
            let error = ErrorUtils.missingAppUserIDError()
            let container = ErrorContainer(error: error, extraPayload: ["extra": "payload"])

            let required: Set<String> = [
                "code",
                "message",
                "readableErrorCode",
                "readable_error_code",
                "underlyingErrorMessage"
            ]
            let missing = required.subtracting(Set(container.info.keys))
            expect(missing).to(beEmpty())
        }

        it("passes the extra payload through untouched") {
            let error = ErrorUtils.missingAppUserIDError()
            let container = ErrorContainer(error: error, extraPayload: ["userCancelled": true])

            expect(container.info["userCancelled"] as? Bool) == true
        }
    }
}

