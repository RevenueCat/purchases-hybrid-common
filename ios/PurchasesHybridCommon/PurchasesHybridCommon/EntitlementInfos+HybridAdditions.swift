//
//  EntitlementInfos+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

internal extension EntitlementInfos {

    var dictionary: [String: Any] {
        let verificationResult: VerificationResult
        if #available(iOS 13.0, *) {
            verificationResult = verification
        } else {
            verificationResult = .notRequested
        }
        return [
            "all": all.mapValues { $0.dictionary },
            "active": active.mapValues { $0.dictionary },
            "verification": verificationResult.name
        ]
    }


}

internal extension VerificationResult {

    var name: String {
        switch self {
        case .notRequested: return "NOT_REQUESTED"
        case .verified: return "VERIFIED"
        case .verifiedOnDevice: return "VERIFIED_ON_DEVICE"
        case .failed: return "FAILED"
        }
    }
}
