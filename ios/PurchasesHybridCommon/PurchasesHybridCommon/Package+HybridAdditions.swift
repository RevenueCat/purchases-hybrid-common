//
//  Package+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

public extension PresentedOfferingContext {

    var dictionary: [String: Any] {
        return [
            "offeringIdentifier": self.offeringIdentifier,
            "placementIdentifier": self.placementIdentifier ?? NSNull(),
            "targetingContext": self.targetingContext?.dictionary ?? NSNull()
        ]
    }

}

public extension PresentedOfferingContext.TargetingContext {

    var dictionary: [String: Any] {
        return [
            "revision": self.revision,
            "ruleId": self.ruleId
        ]
    }

}

public extension Package {

    var dictionary: [String: Any] {
        return dictionary(offeringIdentifier)
    }
    
    func dictionary(_ offeringIdentifier: String) ->  [String: Any] {
        return [
            "identifier": identifier,
            "packageType": packageType.name,
            "product": storeProduct.rc_dictionary,
            "offeringIdentifier": offeringIdentifier,
            "presentedOfferingContext": presentedOfferingContext.dictionary
        ]
    }

}

private extension PackageType {

    var name: String {
        switch self {
        case .unknown:
            return "UNKNOWN"
        case .custom:
            return "CUSTOM"
        case .lifetime:
            return "LIFETIME"
        case .annual:
            return "ANNUAL"
        case .sixMonth:
            return "SIX_MONTH"
        case .threeMonth:
            return "THREE_MONTH"
        case .twoMonth:
            return "TWO_MONTH"
        case .monthly:
            return "MONTHLY"
        case .weekly:
            return "WEEKLY"
        @unknown default:
            return "UNKNOWN"
        }
    }

}
