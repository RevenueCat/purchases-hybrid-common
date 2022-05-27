//
//  CustomerInfo+TestExtensions.swift
//  PurchasesHybridCommonTests
//
//  Created by Will Taylor on 5/27/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation
import RevenueCat

extension CustomerInfo {
    static func fromJSON(_ jsonString: String) -> CustomerInfo? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try! decoder.decode(CustomerInfo.self, from: data)
    }
}
