//
//  ErrorContainer.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

@objc(RCErrorContainer) public class ErrorContainer: NSObject {

    @objc public let code: Int
    @objc public let message: String
    @objc public let info: [String: Any]
    @objc public let error: NSError

    @objc public init(error: Error, extraPayload: [String: Any]) {
        var nsError = error as NSError

        var info = extraPayload
        info["code"] = nsError.code
        info["message"] = nsError.localizedDescription

        let underlyingErrorMessage = (nsError.userInfo[NSUnderlyingErrorKey] as? NSError)?.localizedDescription

        info["underlyingErrorMessage"] = underlyingErrorMessage ?? ""

        if let storeKitError = ErrorContainer.findStoreKitErrorCodeIfAny(nsError) {
            info["storeError"] = [
                "code": storeKitError.code,
                "domain": storeKitError.domain,
                "message": storeKitError.localizedDescription
            ]
        }

        // todo: remove "readable_error_code" and instead send whole user info instead
        // also: code name is already exposed as error.code
        if let readableErrorCode = nsError.userInfo["readable_error_code"] {
            info["readableErrorCode"] = readableErrorCode
            info["readable_error_code"] = readableErrorCode
        }

        // React Native rejects promises with the original error and forwards only that error's
        // userInfo to the JS layer, never this info dictionary. Anything hybrids need therefore has
        // to travel inside userInfo as well.
        var mergedUserInfo = nsError.userInfo
        info.forEach { mergedUserInfo[$0.key] = $0.value }
        nsError = NSError(domain: nsError.domain, code: nsError.code, userInfo: mergedUserInfo)

        self.code = nsError.code
        self.message = nsError.localizedDescription
        self.error = nsError

        self.info = info
    }

    private static func findStoreKitErrorCodeIfAny(_ error: Error) -> NSError? {
        var currentError: NSError? = error as NSError
        var storeKitError: NSError?
        while let underlyingNSError = currentError?.userInfo[NSUnderlyingErrorKey] as? NSError {
            if !underlyingNSError.domain.starts(with: "RevenueCat") {
                storeKitError = underlyingNSError
                break
            } else {
                currentError = underlyingNSError
            }
        }
        return storeKitError
    }
}
