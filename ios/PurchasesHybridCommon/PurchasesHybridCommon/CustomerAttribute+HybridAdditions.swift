//
//  CustomerAttribute+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Copyright © 2026 RevenueCat. All rights reserved.
//

import Foundation
@_spi(Internal) import RevenueCat

internal extension CustomerInfo.Attribute {

    var rc_dictionary: [String: Any] {
        return [
            "key": self.key,
            "value": self.value,
            "lastUpdatedDate": self.lastUpdatedDate.rc_formattedAsISO8601(),
            "lastUpdatedDateMillis": self.lastUpdatedDate.rc_millisecondsSince1970AsDouble()
        ]
    }

}
