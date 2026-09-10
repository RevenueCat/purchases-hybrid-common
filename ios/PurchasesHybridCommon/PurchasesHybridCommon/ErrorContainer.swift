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
        let nsError = error as NSError

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
