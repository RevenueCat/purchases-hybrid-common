//
//  RefundRequestStatus+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Cesar de la Vega on 10/3/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import RevenueCat

public extension RefundRequestStatus {

    var name: String {
        switch self {
        case .userCancelled:
            return "USER_CANCELLED"
        case .success:
            return "SUCCESS"
        case .error:
            return "ERROR"
        }
    }

}
