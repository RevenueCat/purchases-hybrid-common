//
//  PaywallCustomVariables.swift
//  PurchasesHybridCommonUI
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import Foundation
import RevenueCatUI

/// Bridges the loosely typed custom variables hybrid SDKs hand over (`[String: Any]`, where every
/// scalar has already crossed the Objective-C bridge as `NSNumber` or `NSString`) into the typed
/// values `PaywallViewController` expects.
///
/// Every paywall entry point in ``PaywallProxy`` must go through ``apply(_:to:)`` so the type
/// mapping lives in exactly one place.
@available(iOS 15.0, *)
enum PaywallCustomVariables {

    /// Maps a single bridged value. Returns `nil` for types the paywall cannot render.
    ///
    /// Booleans and numbers both arrive as `NSNumber`, and Swift happily casts an `NSNumber`
    /// holding 0 or 1 to `Bool`. Trying `as? Bool` first is therefore wrong: a numeric `1`
    /// would render as "true". Only an `NSNumber` backed by `CFBoolean` is a real boolean.
    static func value(from raw: Any) -> CustomVariableValue? {
        if let stringValue = raw as? String {
            return .string(stringValue)
        }
        if let number = raw as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return .bool(number.boolValue)
            }
            return .number(number.doubleValue)
        }
        return nil
    }

    /// Applies `variables` to `controller`, skipping (and logging) any value that cannot be mapped.
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
