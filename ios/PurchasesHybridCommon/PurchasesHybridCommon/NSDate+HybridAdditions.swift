//
//  NSDate+HybridAdditions.swift
//  PurchasesHybridCommon
//
//  Created by Andrés Boedo on 4/13/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Foundation

// note: This extension is only temporary, since we're
// dropping iOS 11 in the upcoming major
extension Date {

    func rc_formattedAsISO8601() -> String {
        return Self.stringFromDate(self)
    }

    func rc_millisecondsSince1970AsDouble() -> Double {
        return self.timeIntervalSince1970 * 1000.0
    }

}

private extension Date {

    static func stringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone(abbreviation: "GMT") as TimeZone?
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date as Date)
    }

}
