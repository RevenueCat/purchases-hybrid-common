//
//  CheckpointSerialization.swift
//  PurchasesHybridCommonUI
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
import PurchasesHybridCommon
@_spi(Internal) import RevenueCat
@_spi(InviteOnlyCheckpointsApi) import RevenueCatUI

/// Dictionary forms of the checkpoint types, shared by the checkpoint proxies in this module. Internal because
/// the checkpoint types are SPI; bridges only ever see the dictionaries.
@available(iOS 15.0, *)
enum CheckpointSerialization {

    /// `{ flow: { obtainedEntitlements: [{ entitlementInfo }], obtainedProducts: [{ product }] } | null, customer }`.
    static func dictionary(for result: CheckpointResult) -> [String: Any] {
        let customer = result.customer.dictionary
        let entitlements = (customer["entitlements"] as? [String: Any])?["all"] as? [String: Any] ?? [:]
        let flow: Any = result.flow.map { flow -> [String: Any] in
            [
                "obtainedEntitlements": flow.obtainedEntitlements
                    .sorted { $0.entitlementInfo.identifier < $1.entitlementInfo.identifier }
                    .map { ["entitlementInfo": entitlements[$0.entitlementInfo.identifier] ?? NSNull()] },
                "obtainedProducts": flow.obtainedProducts
                    .sorted { $0.product.id < $1.product.id }
                    .map { obtained -> [String: Any] in
                        // The product serializer is only reachable through `Package.dictionary`; using it on the
                        // original product keeps its billing plan and context.
                        let package = Package(identifier: obtained.product.id, packageType: .custom,
                                              storeProduct: obtained.product, offeringIdentifier: "",
                                              webCheckoutUrl: nil)
                        return ["product": package.dictionary["product"] ?? NSNull()]
                    }
            ]
        } ?? NSNull()
        return ["flow": flow, "customer": customer]
    }

    /// Converts bridge values (strings, numbers, booleans) into typed custom variables. Other values are dropped.
    static func customVariables(from values: [String: Any]?) -> [String: CustomVariableValue] {
        return (values ?? [:]).compactMapValues { value -> CustomVariableValue? in
            if let number = value as? NSNumber {
                return CFGetTypeID(number) == CFBooleanGetTypeID()
                    ? .bool(number.boolValue) : .number(number.doubleValue)
            }
            if let string = value as? String { return .string(string) }
            return nil
        }
    }

    static func name(for kind: CheckpointFailureKind) -> String {
        switch kind {
        case .flowCouldNotBeShown: return "flowCouldNotBeShown"
        case .flowActionFailed: return "flowActionFailed"
        case .flowResultSyncFailed: return "flowResultSyncFailed"
        default: return "flowCouldNotBeShown"
        }
    }

}
