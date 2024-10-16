//
//  Offerings+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

@objc public extension Offerings {
    
    // Re-exports currentOfferingForPlacement function for use in hybrids.

    @objc func currentOfferingForPlacement(_ placementIdentifier: String) -> Offering? {
        return self.currentOffering(forPlacement: placementIdentifier)
    }

}

internal extension Offerings {

    var dictionary: [String: Any] {
        var result: [String: Any] = ["all": all.mapValues { $0.dictionary }]
        if let current = current {
            result["current"] = current.dictionary
        }
        
        return result
    }
}
