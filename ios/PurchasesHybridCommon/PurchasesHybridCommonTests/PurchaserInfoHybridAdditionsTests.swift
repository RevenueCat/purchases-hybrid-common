//
//  PurchaserInfoHybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 6/10/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Quick
import Nimble
import PurchasesHybridCommon

class PurchaserInfoHybridAdditionsTests: QuickSpec {

    override func spec() {
        describe("dictionary") {
            context("managementURL") {
                it("contains the management url when it exists") {
                    let purchaserInfo = PartialMockPurchaserInfo()
                    let urlPath = "https://revenuecat.com"
                    let url = URL(string: urlPath)
                    purchaserInfo.stubbedManagementURL = url
                    
                    let dictionary = purchaserInfo.dictionary()
                    expect(dictionary?["managementURL"] as? String) == urlPath
                }
                it ("contains null when the management url doesn't exist") {
                    let purchaserInfo = PartialMockPurchaserInfo()
                    purchaserInfo.stubbedManagementURL = nil
                    
                    let dictionary = purchaserInfo.dictionary()
                    expect(dictionary?["managementURL"] as? NSNull) == NSNull()
                }
            }
        }
    }
}

class PartialMockPurchaserInfo: Purchases.PurchaserInfo {
    
    var stubbedManagementURL: URL?
    
    override var managementURL: URL? {
        return stubbedManagementURL
    }
    
    override var nonConsumablePurchases: Set<String> {
        return Set([])
    }
    
    override var firstSeen: Date {
        return Date()
    }
    
    override var entitlements: Purchases.EntitlementInfos {
        return Purchases.EntitlementInfos()
    }

    override var originalAppUserId: String {
        return "originalAppUserId"
    }
    
    override var requestDate: Date? {
        return Date()
    }
}
