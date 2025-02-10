//
//  IntroEligibility+HybridExtensions.swift
//  PurchasesHybridCommon
//
//  Created by Jay Shortway on 04/02/2025.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

@objc
public extension IntroEligibility {

    // IntroEligibility isn't exposed as a part of the PHC's public API to KMP by default.
    // We can expose it by adding this function to the IntroEligibility class. This function is intentionally a no-op
    // and shouldn't be called anywhere but also shouldn't be removed without ensuring that the IntroEligibility
    // class is exposed to KMP in some other way.
    @objc
    func noOP() {}
}
