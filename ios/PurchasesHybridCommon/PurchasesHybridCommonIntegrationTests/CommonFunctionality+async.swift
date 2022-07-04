//
//  CommonFunctionality+async.swift
//  PurchasesHybridCommonIntegrationTests
//
//  Created by Nacho Soto on 6/27/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

@testable import PurchasesHybridCommon
@testable import RevenueCat

extension CommonFunctionality {

    static func offerings() async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.getOfferings { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

    static func purchase(product productIdentifier: String,
                         signedDiscountTimestamp: String?) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.purchase(product: productIdentifier, signedDiscountTimestamp: signedDiscountTimestamp) { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

    static func purchase(package packageIdentifier: String,
                         offeringIdentifier: String,
                         signedDiscountTimestamp: String?) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.purchase(package: packageIdentifier,
                          offeringIdentifier: offeringIdentifier,
                          signedDiscountTimestamp: signedDiscountTimestamp) { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

    static func customerInfo(fetchPolicy: CacheFetchPolicy = .default) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.customerInfo(fetchPolicy: fetchPolicy) { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

    static func logIn(appUserID: String) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.logIn(appUserID: appUserID) { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

    static func logOut() async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.logOut { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

    static func restorePurchases() async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.restorePurchases { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

}
