//
//  PurchaserInfoHybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 6/10/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Quick
import Nimble
import RevenueCat

class PurchaserInfoHybridAdditionsTests: QuickSpec {

    override func spec() {
        describe("rc_dictionary") {
            context("managementURL") {
                it("contains the management url when it exists") {
                    let purchaserInfo = PartialMockPurchaserInfo()
                    let urlPath = "https://revenuecat.com"
                    let url = URL(string: urlPath)
                    purchaserInfo.stubbedManagementURL = url
                    
                    let dictionary = purchaserInfo.dictionary
                    expect(dictionary["managementURL"] as? String) == urlPath
                }
                it ("contains null when the management url doesn't exist") {
                    let purchaserInfo = PartialMockPurchaserInfo()
                    purchaserInfo.stubbedManagementURL = nil
                    
                    let dictionary = purchaserInfo.dictionary
                    expect(dictionary["managementURL"] as? NSNull) == NSNull()
                }
            }
            context("nonSubscriptionTransactions") {
                it("contains all the non subscription transactions") {
                    let purchaserInfo = PartialMockPurchaserInfo()
                    
                    let transactionDate = Date()
                    let transaction = PurchasesCoreSwift.Transaction(transactionId: "transactionid", productId: "productid", purchaseDate: transactionDate as Date)
                    purchaserInfo.stubbedNonSubscriptionTransactions = [transaction]
                    
                    let dictionary = purchaserInfo.dictionary
                    let nonSubscriptionTransactions = dictionary["nonSubscriptionTransactions"] as? Array<Any>
                    expect(nonSubscriptionTransactions?.count) == 1
                    
                    let transactionDictionary = nonSubscriptionTransactions?[0] as? Dictionary<String, Any>
                    expect(transactionDictionary?["revenueCatId"] as? String) == transaction.revenueCatId
                    expect(transactionDictionary?["productId"] as? String) == transaction.productId
                    expect(transactionDictionary?["purchaseDateMillis"] as? Double) == (transactionDate as NSDate).rc_millisecondsSince1970AsDouble()
                    
                    let dateformatter = ISO8601DateFormatter()
                    expect(transactionDictionary?["purchaseDate"] as? String) == dateformatter.string(from: transactionDate as Date)
                }
                it ("is empty when there are no non subscription transactions") {
                    let purchaserInfo = PartialMockPurchaserInfo()
                
                    let dictionary = purchaserInfo.dictionary
                    let nonSubscriptionTransactions = dictionary["nonSubscriptionTransactions"] as? Array<Any>
                    expect(nonSubscriptionTransactions?.count) == 0
                }
            }
        }
    }
}

class PartialMockPurchaserInfo: Purchases.PurchaserInfo {
    
    var stubbedManagementURL: URL?
    var stubbedNonSubscriptionTransactions: Array = Array<PurchasesCoreSwift.Transaction>()
    let _firstSeen = Date()
    let _requestDate = Date()
    
    override var managementURL: URL? {
        return stubbedManagementURL
    }
    
    override var nonConsumablePurchases: Set<String> {
        return Set([])
    }
    
    override var firstSeen: Date {
        return _firstSeen
    }
    
    override var entitlements: Purchases.EntitlementInfos {
        return Purchases.EntitlementInfos()
    }

    override var originalAppUserId: String {
        return "originalAppUserId"
    }
    
    override var requestDate: Date? {
        return _requestDate
    }
    
    override var nonSubscriptionTransactions: [PurchasesCoreSwift.Transaction] {
        return stubbedNonSubscriptionTransactions
    }
}
