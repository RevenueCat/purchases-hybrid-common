//
//  PaywallCustomVariables.swift
//  PurchasesHybridCommonUI
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Foundation
import RevenueCatUI

/// Maps the untyped custom variables hybrid SDKs pass to `CustomVariableValue`.
@available(iOS 15.0, *)
enum PaywallCustomVariables {

    static func value(from raw: Any) -> CustomVariableValue? {
        if let stringValue = raw as? String {
            return .string(stringValue)
        }
        if let number = raw as? NSNumber {
            // Numbers and booleans both arrive as NSNumber, and `as? Bool` succeeds for 0 and 1.
            // Only a CFBoolean-backed NSNumber is a real boolean.
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return .bool(number.boolValue)
            }
            return .number(number.doubleValue)
        }
        return nil
    }

    static func apply(_ variables: [String: Any]?, to controller: PaywallViewController) {
        variables?.forEach { key, raw in
            guard let value = value(from: raw) else {
                NSLog("Custom variable '%@' has unsupported type %@. " +
                      "Only String, Number, and Boolean values are supported. This variable will be ignored.",
                      key, String(describing: type(of: raw)))
                return
            }
            controller.customVariables[key] = value
        }
    }

}

#endif
