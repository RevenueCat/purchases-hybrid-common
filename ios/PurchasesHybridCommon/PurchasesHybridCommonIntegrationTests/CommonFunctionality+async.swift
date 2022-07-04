//
//  CommonFunctionality+async.swift
//  PurchasesHybridCommonIntegrationTests
//
//  Created by Nacho Soto on 6/27/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import PurchasesHybridCommon

@testable import RevenueCat

extension CommonFunctionality {

    static func offerings() async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            Self.getOfferings { dictionary, error in
                continuation.resume(with: Result(dictionary, error?.error))
            }
        }
    }

}
