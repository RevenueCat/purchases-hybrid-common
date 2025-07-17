//
//  CommonFunctionality+async.swift
//  PurchasesHybridCommonIntegrationTests
//
//  Created by Nacho Soto on 6/27/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

@testable import PurchasesHybridCommon
@testable import RevenueCat

enum PlacementOffering {
    case offering([String: Any]), none

    var rawValue: [String: Any]? {
        switch self {
        case .offering(let dict):
            return dict
        case .none:
            return nil
        }
    }
}

extension CommonFunctionality {

    static func offerings() async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.getOfferings { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

    static func currentOffering(forPlacement placement: String) async throws -> [String: Any]? {
        let value: PlacementOffering = try await withCheckedThrowingContinuation { continuation in
            Self.getCurrentOffering(forPlacement: placement) { dictionary, error in
                let v: PlacementOffering
                if let dictionary {
                    v = .offering(dictionary)
                } else {
                    v = .none
                }

                continuation.resume(with: Result(v, error?.error))
            }
        }

        return value.rawValue
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
                         presentedOfferingContext: [String: Any?],
                         signedDiscountTimestamp: String?) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.purchase(package: packageIdentifier,
                          presentedOfferingContext: presentedOfferingContext,
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

    static func syncPurchases() async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.syncPurchases { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

    static func checkTrialOrIntroductoryPriceEligibility(for products: [String]) async -> [String: Any] {
        return await withCheckedContinuation { continuation in
            Self.checkTrialOrIntroductoryPriceEligibility(for: products) { dictionary in
                continuation.resume(returning: dictionary)
            }
        }
    }

    static func promotionalOffer(
        for productIdentifier: String,
        discountIdentifier: String?
    ) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.promotionalOffer(for: productIdentifier,
                                  discountIdentifier: discountIdentifier) { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

}
