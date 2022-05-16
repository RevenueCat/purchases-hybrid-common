//
//  CustomerInfo+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 6/10/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Quick
import Nimble
@testable import PurchasesHybridCommon
@testable import RevenueCat

class CustomerInfoHybridAdditionsTests: QuickSpec {

    override func spec() {
        describe("rc_dictionary") {
            context("managementURL") {
                it("contains the management url when it exists") {
                    let mockCustomerInfo = try CustomerInfo(data: [
                        "request_date": "2019-08-16T10:30:42Z",
                        "subscriber": [
                            "first_seen": "2019-07-17T00:05:54Z",
                            "management_url": "https://revenuecat.com",
                            "original_app_user_id": "",
                            "subscriptions": [:],
                            "other_purchases": [:]
                        ]])

                    let urlPath = "https://revenuecat.com"

                    let dictionary = mockCustomerInfo.dictionary
                    expect(dictionary["managementURL"] as? String) == urlPath
                }
                it ("contains null when the management url doesn't exist") {
                    let mockCustomerInfo = try CustomerInfo(data: [
                        "request_date": "2019-08-16T10:30:42Z",
                        "subscriber": [
                            "first_seen": "2019-07-17T00:05:54Z",
                            "original_app_user_id": "",
                            "subscriptions": [:],
                            "other_purchases": [:]
                        ]])

                    let dictionary = mockCustomerInfo.dictionary
                    expect(dictionary["managementURL"] as? NSNull) == NSNull()
                }
            }
            context("nonSubscriptionTransactions") {
                it("contains all the non subscription transactions") {
                    let transactionDateString = "1990-08-30T02:40:36Z"

                    let mockCustomerInfo = try CustomerInfo(data: [
                        "request_date": "2019-08-16T10:30:42Z",
                        "subscriber": [
                            "original_app_user_id": "app_user_id",
                            "first_seen": "2019-06-17T16:05:33Z",
                            "subscriptions": [:],
                            "non_subscriptions": [
                                "productid": [
                                    [
                                        "id": "transactionid",
                                        "is_sandbox": true,
                                        "original_purchase_date": "1990-08-30T02:40:36Z",
                                        "purchase_date": transactionDateString,
                                        "store": "play_store"
                                    ]
                                ]
                            ]
                        ]])

                    let dateformatter = ISO8601DateFormatter()
                    let transactionDate = dateformatter.date(from: transactionDateString)!

                    let dictionary = mockCustomerInfo.dictionary
                    let nonSubscriptionTransactions = dictionary["nonSubscriptionTransactions"] as? Array<Any>
                    expect(nonSubscriptionTransactions?.count) == 1

                    let transactionDictionary = nonSubscriptionTransactions?[0] as? Dictionary<String, Any>
                    expect(transactionDictionary?["revenueCatId"] as? String) == "transactionid"
                    expect(transactionDictionary?["productId"] as? String) == "productid"
                    expect(transactionDictionary?["purchaseDateMillis"] as? Double) == transactionDate.rc_millisecondsSince1970AsDouble()


                    expect(transactionDictionary?["purchaseDate"] as? String) == dateformatter.string(from: transactionDate as Date)
                }
                it ("is empty when there are no non subscription transactions") {
                    let mockCustomerInfo = try CustomerInfo(data: [
                        "request_date": "2019-08-16T10:30:42Z",
                        "subscriber": [
                            "first_seen": "2019-07-17T00:05:54Z",
                            "original_app_user_id": "",
                            "subscriptions": [:],
                            "other_purchases": [:]
                        ]])

                    let dictionary = mockCustomerInfo.dictionary
                    let nonSubscriptionTransactions = dictionary["nonSubscriptionTransactions"] as? Array<Any>
                    expect(nonSubscriptionTransactions?.count) == 0
                }
            }
        }
    }
}
