//
//  NSDateHybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 4/27/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Quick
import Nimble
import PurchasesHybridCommon

class NSDateHybridAdditionsTests: QuickSpec {

    override func spec() {
        describe("stringFromDate") {
            it("returns strings in iso8601") {
                let dateformatter = ISO8601DateFormatter()

                let date1 = NSDate(timeIntervalSince1970: 1588028019)
                expect(date1.formattedAsISO8601()) == "2020-04-27T22:53:39Z"
                expect(dateformatter.string(from: date1 as Date)) == date1.formattedAsISO8601()

                let date2 = NSDate(timeIntervalSince1970: 1588027325)
                expect(date2.formattedAsISO8601()) == "2020-04-27T22:42:05Z"
                expect(dateformatter.string(from: date2 as Date)) == date2.formattedAsISO8601()

                let date3 = NSDate(timeIntervalSince1970: 1588327605)
                expect(date3.formattedAsISO8601()) == "2020-05-01T10:06:45Z"
                expect(dateformatter.string(from: date3 as Date)) == date3.formattedAsISO8601()

                let date4 = NSDate(timeIntervalSince1970: 1588044611)
                expect(date4.formattedAsISO8601()) == "2020-04-28T03:30:11Z"
                expect(dateformatter.string(from: date4 as Date)) == date4.formattedAsISO8601()
            }
        }

        describe("millisecondsSince1970") {
            it("correctly returns results in milliseconds") {
                let date = NSDate(timeIntervalSince1970: 1588044611)
                expect(date.millisecondsSince1970()) == date.timeIntervalSince1970 * 1000.0

                let now = NSDate()
                expect(now.millisecondsSince1970) == now.timeIntervalSince1970 * 1000.0
            }
        }
    }
}
