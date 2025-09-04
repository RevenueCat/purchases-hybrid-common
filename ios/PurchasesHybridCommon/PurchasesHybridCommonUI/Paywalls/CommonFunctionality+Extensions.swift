//
//  CommonFunctionality+Extensions.swift
//  PurchasesHybridCommon
//
//  Created by Josh Holtz on 9/3/25.
//  Copyright © 2025 RevenueCat. All rights reserved.
//

#if !os(macOS) && !os(tvOS) && !os(watchOS)

import PurchasesHybridCommon
import RevenueCat
import RevenueCatUI

extension CommonFunctionality {

    @objc public static func overridePreferredLocale(_ locale: String?) {
        Purchases.shared.overridePreferredUILocale(locale)
    }

}

#endif
