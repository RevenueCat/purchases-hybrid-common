//
//  DangerousSettings+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
@_spi(Internal) @_spi(Experimental) import RevenueCat

@objc public extension DangerousSettings {

    /// Creates a ``DangerousSettings`` with the given values.
    ///
    /// `useWorkflows` is only exposed through RevenueCat's `@_spi(Internal)` API, so hybrid SDKs can't
    /// construct ``DangerousSettings`` with it directly. This bridges it into the Objective-C-visible surface.
    @objc(createDangerousSettingsWithAutoSyncPurchases:useWorkflows:)
    static func createDangerousSettings(autoSyncPurchases: Bool,
                                        useWorkflows: Bool) -> DangerousSettings {
        DangerousSettings(autoSyncPurchases: autoSyncPurchases, useWorkflows: useWorkflows)
    }

}
