//
//  Date+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 4/27/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Quick
import Nimble
@testable import PurchasesHybridCommon

class NSDateHybridAdditionsTests: QuickSpec {

    override func spec() {
        describe("stringFromDate") {
            it("returns strings in iso8601") {
                let dateformatter = ISO8601DateFormatter()

                let date1 = Date(timeIntervalSince1970: 1588028019)
                expect(date1.rc_formattedAsISO8601()) == "2020-04-27T22:53:39Z"
                expect(dateformatter.string(from: date1 as Date)) == date1.rc_formattedAsISO8601()

                let date2 = Date(timeIntervalSince1970: 1588027325)
                expect(date2.rc_formattedAsISO8601()) == "2020-04-27T22:42:05Z"
                expect(dateformatter.string(from: date2 as Date)) == date2.rc_formattedAsISO8601()

                let date3 = Date(timeIntervalSince1970: 1588327605)
                expect(date3.rc_formattedAsISO8601()) == "2020-05-01T10:06:45Z"
                expect(dateformatter.string(from: date3 as Date)) == date3.rc_formattedAsISO8601()

                let date4 = Date(timeIntervalSince1970: 1588044611)
                expect(date4.rc_formattedAsISO8601()) == "2020-04-28T03:30:11Z"
                expect(dateformatter.string(from: date4 as Date)) == date4.rc_formattedAsISO8601()
            }
        }

        describe("rc_millisecondsSince1970AsDouble") {
            it("correctly returns results in milliseconds") {
                let date = Date(timeIntervalSince1970: 1588044611)
                expect(date.rc_millisecondsSince1970AsDouble()) == 1588044611000.0

                let now = Date()
                expect(now.rc_millisecondsSince1970AsDouble()) == now.timeIntervalSince1970 * 1000.0
            }
        }
    }
}
