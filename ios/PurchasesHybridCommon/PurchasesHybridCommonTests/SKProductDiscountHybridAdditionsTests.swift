//
//  SKProductDiscountHybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Andrés Boedo on 4/22/20.
//  Copyright © 2020 RevenueCat. All rights reserved.
//

import Quick
import Nimble
import StoreKit
import Purchases
import PurchasesHybridCommon

class SkuProductDiscountHybridAdditionsTests: QuickSpec {
    override func spec() {
        describe("dictionary") {
            it("has the right format") {
                let subscriptionPeriod = SKProductSubscriptionPeriod(numberOfUnits: 3, unit: .month)
                let productDiscount = SKProductDiscount(price: 10.99,
                                                        priceLocale: Locale.current,
                                                        identifier: "product discount",
                                                        subscriptionPeriod: subscriptionPeriod,
                                                        numberOfPeriods: 3,
                                                        paymentMode: SKProductDiscount.PaymentMode.payAsYouGo,
                                                        type: .introductory)
                guard let receivedDictionary = productDiscount.dictionary() as? [String: NSObject] else {
                    fatalError("received dictionary is not in the right format")
                }
                
                expect(receivedDictionary["cycles"] as? NSNumber) == 3
                expect(receivedDictionary["identifier"] as? NSString) == "product discount"
                expect(receivedDictionary["period"] as? NSString) == "P3M"
                expect(receivedDictionary["periodNumberOfUnits"] as? NSNumber) == 3
                expect(receivedDictionary["periodUnit"] as? NSString) == "MONTH"
                expect(receivedDictionary["price"] as? NSNumber).to(beCloseTo(10.99))
                expect(receivedDictionary["priceString"] as? NSString) == "$10.99"
            }
        }
    }
}

public extension SKProductDiscount {
    convenience init(price: NSDecimalNumber,
                     priceLocale: Locale,
                     identifier: String,
                     subscriptionPeriod: SKProductSubscriptionPeriod,
                     numberOfPeriods: UInt,
                     paymentMode: SKProductDiscount.PaymentMode,
                     type: SKProductDiscount.`Type`) {
        self.init()
        self.setValue(price, forKey: "price")
        self.setValue(priceLocale, forKey: "priceLocale")
        self.setValue(identifier, forKey: "identifier")
        self.setValue(subscriptionPeriod, forKey: "subscriptionPeriod")
        self.setValue(numberOfPeriods, forKey: "numberOfPeriods")
        self.setValue(paymentMode.rawValue, forKey: "paymentMode")
        self.setValue(type.rawValue, forKey: "type")
    }
}

private extension SKProductSubscriptionPeriod {
    convenience init(numberOfUnits: Int,
                     unit: SKProduct.PeriodUnit) {
        self.init()
        self.setValue(numberOfUnits, forKey: "numberOfUnits")
        self.setValue(unit.rawValue, forKey: "unit")
    }
}
