//
//  WinBackOffer+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Will Taylor on 11/18/24.
//  Copyright © 2024 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

@objc public extension WinBackOffer {

    var rc_dictionary: [String: Any] {
        return self.discount.rc_dictionary
    }

}
