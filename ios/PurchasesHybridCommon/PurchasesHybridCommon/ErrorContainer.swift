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

        // Only ErrorUtils sets "readable_error_code". Errors built from a bare ErrorCode or
        // from NSError(domain: ErrorCode.errorDomain, code:) carry the code but not the name.
        if let readableErrorCode = nsError.userInfo["readable_error_code"]
            ?? ErrorContainer.codeName(for: nsError) {
            info["readableErrorCode"] = readableErrorCode
            info["readable_error_code"] = readableErrorCode
        }

        self.code = nsError.code
        self.message = nsError.localizedDescription
        self.error = nsError

        self.info = info
    }

    // ErrorCode.codeName is internal to purchases-ios; its CustomNSError conformance
    // exposes the same value under "rc_code_name".
    private static func codeName(for error: NSError) -> Any? {
        guard error.domain == ErrorCode.errorDomain, let code = ErrorCode(rawValue: error.code) else {
            return nil
        }
        return (code as NSError).userInfo["rc_code_name"]
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
