//
//  SKPaymentDiscountExtensions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
// todo: expose signedData in promotionalOffer in purchases-ios
@testable import RevenueCat

@objc public extension PromotionalOffer {

    var rc_dictionary: [String: Any] {
        return [
            "identifier": signedData.identifier,
            "keyIdentifier": signedData.keyIdentifier,
            "nonce": signedData.nonce.uuidString,
            "signature": signedData.signature,
            "timestamp": signedData.timestamp
        ]
    }

}
