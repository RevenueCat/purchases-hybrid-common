//
//  EntitlementVerificationMode+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Nacho Soto on 6/27/23.
//

import RevenueCat

extension Configuration.EntitlementVerificationMode {

    var name: String {
        switch self {
        case .disabled: return "DISABLED"
        case .informational: return "INFORMATIONAL"
        case .enforced: return "ENFORCED"
        }
    }

    init?(name: String) {
        if let mode = Self.modesByName[name] {
            self = mode
        } else {
            return nil
        }
    }

    private static let modesByName: [String: Self] = Dictionary(uniqueKeysWithValues: [
        Self.disabled,
        Self.informational,
        // Disabled temporarily since enforced is not available yet.
        // Self.enforced
    ].map { ($0.name, $0) })

}
