//
//  StoreProduct+HybridAdditionsTests.swift
//  PurchasesHybridCommonTests
//
//  Created by Cesar de la Vega on 12/27/22.
//  Copyright © 2022 RevenueCat. All rights reserved.
//

import Quick
import Nimble
import StoreKit
@testable import PurchasesHybridCommon
@testable import RevenueCat

class StoreProductHybridAdditionsTests: QuickSpec {

    private func storeProductDictionary(with locale: Locale = Locale(identifier: "en_US"),
                                            description: String = "A product description",
                                            productIdentifier: String = "monthly",
                                            price: Decimal = Decimal(1.0),
                                            title: String = "Monthly Product",
                                            introductoryPrice: SKProductDiscount? = nil,
                                            discounts: [SKProductDiscount] = [],
                                            subscriptionPeriod: SKProductSubscriptionPeriod? = nil
    ) -> [String: NSObject] {
        let storeProduct = StoreProduct(priceLocale: locale,
                                        localizedDescription: description,
                                        discounts: discounts,
                                        productIdentifier: productIdentifier,
                                        introductoryDiscount: nil,
                                        price: price,
                                        productType: .autoRenewableSubscription,
                                        localizedTitle: title,
                                        subscriptionPeriod: subscriptionPeriod,
                                        subscriptionGroupIdentifier: "sub_group",
                                        introductoryPrice: introductoryPrice
        )
        guard let receivedDictionary = storeProduct.rc_dictionary as? [String: NSObject] else {
            fatalError("received rc_dictionary is not in the right format")
        }
        return receivedDictionary
    }

    override func spec() {
        describe("rc_dictionary") {
            it("maps currency code correctly") {
                let receivedDictionary = self.storeProductDictionary(with: Locale(identifier: "en_CA"))

                expect(receivedDictionary["currencyCode"] as? NSString) == "CAD"
            }
            it("maps description correctly") {
                let expected = "Testing description"
                let receivedDictionary = self.storeProductDictionary(description: expected)

                expect(receivedDictionary["description"] as? NSString) == expected as NSString
            }
            it("maps identifier correctly") {
                let expected = "annual"
                let receivedDictionary = self.storeProductDictionary(productIdentifier: expected)

                expect(receivedDictionary["identifier"] as? NSString) == expected as NSString
            }
            it("maps price correctly") {
                let expected = Decimal(2.00)

                let receivedDictionary = self.storeProductDictionary(price: expected)

                expect(receivedDictionary["price"] as? Decimal) == expected
                expect(receivedDictionary["priceString"] as? NSString) == "$2.00"
            }
            it("maps productCategory correctly") {
                var receivedDictionary = self.storeProductDictionary(subscriptionPeriod: SKProductSubscriptionPeriod(numberOfUnits: 1, unit: .month))

                expect(receivedDictionary["productCategory"] as? NSString) == "SUBSCRIPTION"

                receivedDictionary = self.storeProductDictionary(subscriptionPeriod: nil)

                expect(receivedDictionary["productCategory"] as? NSString) == "NON_SUBSCRIPTION"
            }
            it("maps productType to NON_CONSUMABLE for SK1Products") {
                let receivedDictionary = self.storeProductDictionary()

                expect(receivedDictionary["productType"] as? NSString) == "NON_CONSUMABLE"
            }
            it("maps title correctly") {
                let expected = "Testing product title"
                let receivedDictionary = self.storeProductDictionary(title: expected)

                expect(receivedDictionary["title"] as? NSString) == expected as NSString
            }
            it("maps discounts correctly") {
                var receivedDictionary = self.storeProductDictionary()

                expect(receivedDictionary["discounts"] as? [SKProductDiscount]) == []

                let subscriptionPeriod = SKProductSubscriptionPeriod(numberOfUnits: 3, unit: .month)
                let productDiscount = SKProductDiscount(price: 10.99,
                                                        priceLocale: Locale.current,
                                                        identifier: "product discount",
                                                        subscriptionPeriod: subscriptionPeriod,
                                                        numberOfPeriods: 3,
                                                        paymentMode: SKProductDiscount.PaymentMode.payAsYouGo,
                                                        type: .introductory)
                receivedDictionary = self.storeProductDictionary(discounts: [productDiscount])

                let receivedDiscounts = try XCTUnwrap(receivedDictionary["discounts"] as? NSArray)
                expect(receivedDiscounts.count) == 1
            }
            it("maps intro price correctly") {
                var receivedDictionary = self.storeProductDictionary()

                expect(receivedDictionary["introPrice"] as? SKProductDiscount?) == nil
                let subscriptionPeriod = SKProductSubscriptionPeriod(numberOfUnits: 3, unit: .month)
                let productDiscount = SKProductDiscount(price: 10.99,
                                                        priceLocale: Locale.current,
                                                        identifier: "product discount",
                                                        subscriptionPeriod: subscriptionPeriod,
                                                        numberOfPeriods: 3,
                                                        paymentMode: SKProductDiscount.PaymentMode.payAsYouGo,
                                                        type: .introductory)
                receivedDictionary = self.storeProductDictionary(introductoryPrice: productDiscount)
                let receivedIntroPrice = try XCTUnwrap(receivedDictionary["introPrice"] as? [String:Any])
                expect(receivedIntroPrice["price"] as? Decimal) == 10.99
            }
            it("maps subscription period correctly") {
                var receivedDictionary = self.storeProductDictionary()

                expect(receivedDictionary["subscriptionPeriod"] as? NSString) == nil

                receivedDictionary = self.storeProductDictionary(subscriptionPeriod: SKProductSubscriptionPeriod(numberOfUnits: 1, unit: .month))
                expect(receivedDictionary["subscriptionPeriod"] as? NSString) == "P1M"

                receivedDictionary = self.storeProductDictionary(subscriptionPeriod: SKProductSubscriptionPeriod(numberOfUnits: 1, unit: .year))
                expect(receivedDictionary["subscriptionPeriod"] as? NSString) == "P1Y"
            }
            it("rc_dictionary has correct size") {
                let receivedDictionary = self.storeProductDictionary()

                expect(receivedDictionary.count) == 11
            }
        }
    }
}

extension StoreProduct {
    convenience init(priceLocale: Locale,
                     localizedDescription: String,
                     discounts: [SKProductDiscount],
                     productIdentifier: String,
                     introductoryDiscount: StoreProductDiscount?,
                     price: Decimal,
                     productType: ProductType,
                     localizedTitle: String,
                     subscriptionPeriod: SKProductSubscriptionPeriod?,
                     subscriptionGroupIdentifier: String,
                     introductoryPrice: SKProductDiscount?
    ) {
        let skProduct = SKProduct(localizedDescription: localizedDescription,
                                  localizedTitle: localizedTitle,
                                  price: price,
                                  priceLocale: priceLocale,
                                  productIdentifier: productIdentifier,
                                  subscriptionPeriod: subscriptionPeriod,
                                  introductoryPrice: introductoryPrice,
                                  subscriptionGroupIdentifier: subscriptionGroupIdentifier,
                                  discounts: discounts)

        self.init(sk1Product: skProduct)
    }
}

extension SKProduct {
    convenience init(localizedDescription: String,
                     localizedTitle: String,
                     price: Decimal,
                     priceLocale: Locale,
                     productIdentifier: String,
                     subscriptionPeriod: SKProductSubscriptionPeriod?,
                     introductoryPrice: SKProductDiscount?,
                     subscriptionGroupIdentifier: String?,
                     discounts: [SKProductDiscount]
    ) {
        self.init()
        self.setValue(localizedDescription, forKey: "localizedDescription")
        self.setValue(localizedTitle, forKey: "localizedTitle")
        self.setValue(price, forKey: "price")
        self.setValue(priceLocale, forKey: "priceLocale")
        self.setValue(productIdentifier, forKey: "productIdentifier")
        self.setValue(subscriptionPeriod, forKey: "subscriptionPeriod")
        self.setValue(introductoryPrice, forKey: "introductoryPrice")
        self.setValue(subscriptionGroupIdentifier, forKey: "subscriptionGroupIdentifier")
        self.setValue(discounts, forKey: "discounts")
    }
}

