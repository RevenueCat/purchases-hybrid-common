//
//  SKPaymentDiscountExtensions.swift
//  PurchasesHybridCommonSwift
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import StoreKit

@available(iOS 12.2, tvOS 12.2, watchOS 6.2, macOS 10.14.4, *)
@objc public extension SKPaymentDiscount {

    @objc var rc_dictionary: [String: Any] {
        return [
            "identifier": identifier,
            "keyIdentifier": keyIdentifier,
            "nonce": nonce.uuidString,
            "signature": signature,
            "timestamp": timestamp
        ]
    }

}
