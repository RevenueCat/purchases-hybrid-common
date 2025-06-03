//
//  Enum+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Toni Rico on 3/3/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

internal extension PeriodType {

    var periodTypeString: String {
        switch self {
        case .intro:
            return "INTRO"
        case .normal:
            return "NORMAL"
        case .trial:
            return "TRIAL"
        case .prepaid:
            return "PREPAID"
        @unknown default:
            return "UNKNOWN"
        }
    }

}

internal extension PurchaseOwnershipType {

    var ownershipTypeString: String {
        switch self {
        case .familyShared:
            return "FAMILY_SHARED"
        case .unknown:
            return "UNKNOWN"
        case .purchased:
            return "PURCHASED"
        @unknown default:
            return "UNKNOWN"
        }
    }

}

internal extension Store {

    var storeString: String {
        switch self {
        case .appStore:
            return "APP_STORE"
        case .macAppStore:
            return "MAC_APP_STORE"
        case .playStore:
            return "PLAY_STORE"
        case .promotional:
            return "PROMOTIONAL"
        case .unknownStore:
            return "UNKNOWN_STORE"
        case .amazon:
            return "AMAZON"
        case .stripe:
            return "STRIPE"
        case .rcBilling:
            return "RC_BILLING"
        case .external:
            return "EXTERNAL"
        case .paddle:
            return "PADDLE"
        @unknown default:
            return "UNKNOWN_STORE"
        }
    }

}
