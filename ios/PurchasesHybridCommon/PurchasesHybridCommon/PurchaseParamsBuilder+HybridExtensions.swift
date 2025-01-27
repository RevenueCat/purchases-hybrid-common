//
//  PurchaseParamsBuilder+HybridExtensions.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 1/23/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

@objc
public extension PurchaseParams.Builder {

    // PurchaseParams.Builder isn't exposed as a part of the PHC's public API to KMP by default.
    // We can expose it by adding this function to the PurchaseParams.Builder class. This function is intentionally a no-op
    // and shouldn't be called anywhere but also shouldn't be removed without ensuring that the PurchaseParams.Builder
    // class is exposed to KMP in some other way.
    @objc
    func noOP() {}
}
