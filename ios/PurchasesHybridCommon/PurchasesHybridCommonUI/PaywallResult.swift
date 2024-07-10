//
//  PaywallResult.swift
//  PurchasesHybridCommonUI
//
//  Created by Antonio Rico Diez on 4/1/24.
//  Copyright © 2024 RevenueCat. All rights reserved.
//

import RevenueCat

internal enum PaywallResult {
    case notPresented
    case purchased
    case restored
    case cancelled

    var name: String {
        switch self {
        case .notPresented: return "NOT_PRESENTED"
        case .purchased: return "PURCHASED"
        case .restored: return "RESTORED"
        case .cancelled: return "CANCELLED"
        }
    }
}
