//
//  StoreKitVersion+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by mark on 19/2/24.
//  Copyright © 2024 RevenueCat. All rights reserved.
//

import RevenueCat

public extension StoreKitVersion {

    var name: String {
        switch self {
        case .storeKit1: return "STOREKIT_1"
        case .storeKit2: return "STOREKIT_2"
        }
    }

    init?(name: String) {
        if let mode = Self.modesByName[name] {
            self = mode
        } else {
            return nil
        }
    }

    private static let modesByName: [String: Self] = [
        "DEFAULT": Self.default,
        Self.storeKit1.name: Self.storeKit1,
        Self.storeKit2.name: Self.storeKit2,
    ]

}
